defmodule Learnflow.Payments do
  import Ecto.Query

  alias Learnflow.Accounts.User
  alias Learnflow.Dashboard.{Playlist, PlaylistVideo}
  alias Learnflow.Payments.Purchase
  alias Learnflow.Repo

  @platform_fee_bps 1_500

  def onboard_creator(%User{} = user) do
    with {:ok, account_id} <- ensure_stripe_account(user),
         {:ok, link} <- stripe_post("/v1/account_links", %{
           account: account_id,
           refresh_url: "#{frontend_url()}/dashboard?tab=earnings",
           return_url: "#{frontend_url()}/dashboard?tab=earnings",
           type: "account_onboarding"
         }) do
      {:ok, link["url"]}
    end
  end

  def handle_onboarding_complete(stripe_account_id) do
    case Repo.get_by(User, stripe_account_id: stripe_account_id) do
      nil -> {:error, :not_found}
      user -> user |> Ecto.Changeset.change(stripe_onboarding_complete: true) |> Repo.update()
    end
  end

  def create_payment_intent(%User{} = user, %Playlist{} = course) do
    cond do
      not course.is_paid or course.price_cents <= 0 ->
        {:error, :course_is_free}

      has_completed_purchase?(user.id, course.id) ->
        {:error, :already_purchased}

      true ->
        payout = creator_payout(course.price_cents)

        with {:ok, intent} <-
               stripe_post("/v1/payment_intents", %{
                 amount: course.price_cents,
                 currency: "usd",
                 automatic_payment_methods: %{enabled: true},
                 metadata: %{user_id: user.id, course_id: course.id}
               }),
             {:ok, purchase} <-
               %Purchase{}
               |> Purchase.changeset(%{
                 user_id: user.id,
                 course_id: course.id,
                 stripe_payment_intent_id: intent["id"],
                 amount_cents: course.price_cents,
                 creator_payout_cents: payout,
                 status: "pending"
               })
               |> Repo.insert(on_conflict: [set: [amount_cents: course.price_cents, creator_payout_cents: payout, status: "pending"]], conflict_target: [:user_id, :course_id]) do
          {:ok, %{client_secret: intent["client_secret"], purchase: purchase}}
        end
    end
  end

  def confirm_purchase(payment_intent_id) do
    case Repo.get_by(Purchase, stripe_payment_intent_id: payment_intent_id) do
      nil ->
        {:error, :not_found}

      purchase ->
        purchase = Repo.preload(purchase, course: [:user])

        Repo.transaction(fn ->
          completed =
            purchase
            |> Purchase.changeset(%{status: "completed"})
            |> Repo.update!()

          maybe_transfer_to_creator(completed)
          completed
        end)
    end
  end

  def has_access?(user_id, course_id) when is_nil(course_id) or is_nil(user_id), do: false

  def has_access?(user_id, course_id) do
    case Repo.get(Playlist, course_id) do
      nil -> false
      %Playlist{is_paid: false} -> true
      %Playlist{user_id: ^user_id} -> true
      %Playlist{} -> has_completed_purchase?(user_id, course_id)
    end
  end

  def course_access(%User{} = user, %Playlist{} = course) do
    %{has_access: has_access?(user.id, course.id), is_paid: course.is_paid, price_cents: course.price_cents}
  end

  def video_access?(user_id, video_id) do
    memberships =
      Repo.all(
        from pv in PlaylistVideo,
          join: c in assoc(pv, :playlist),
          where: pv.video_id == ^video_id and c.status == "published",
          select: %{course_id: pv.playlist_id, course_user_id: c.user_id, is_paid: c.is_paid, position: pv.position}
      )

    cond do
      memberships == [] ->
        true

      Enum.any?(memberships, fn m -> not m.is_paid or m.course_user_id == user_id or m.position < 2 end) ->
        true

      true ->
        Enum.any?(memberships, &has_access?(user_id, &1.course_id))
    end
  end

  def get_creator_stats(%User{} = creator) do
    course_ids = Repo.all(from c in Playlist, where: c.user_id == ^creator.id, select: c.id)

    completed = from p in Purchase, where: p.course_id in ^course_ids and p.status == "completed"

    total_revenue = Repo.one(from p in completed, select: coalesce(sum(p.creator_payout_cents), 0))
    total_students = Repo.one(from p in completed, select: count(fragment("DISTINCT ?", p.user_id)))
    since = DateTime.utc_now() |> DateTime.add(-30, :day) |> DateTime.truncate(:microsecond)
    this_month = Repo.one(from p in completed, where: p.inserted_at >= ^since, select: coalesce(sum(p.creator_payout_cents), 0))

    per_course =
      Repo.all(
        from c in Playlist,
          left_join: p in Purchase,
          on: p.course_id == c.id and p.status == "completed",
          where: c.user_id == ^creator.id,
          group_by: [c.id, c.title],
          select: %{course_id: c.id, title: c.title, students: count(p.user_id), revenue_cents: coalesce(sum(p.creator_payout_cents), 0)}
      )

    chart =
      Repo.all(
        from p in completed,
          where: p.inserted_at >= ^since,
          group_by: fragment("date(?)", p.inserted_at),
          order_by: fragment("date(?)", p.inserted_at),
          select: %{date: fragment("date(?)", p.inserted_at), revenue_cents: coalesce(sum(p.creator_payout_cents), 0)}
      )

    %{
      total_revenue_cents: total_revenue || 0,
      this_month_cents: this_month || 0,
      students_count: total_students || 0,
      per_course: per_course,
      chart: chart,
      onboarding_complete: creator.stripe_onboarding_complete,
      stripe_account_id: creator.stripe_account_id
    }
  end

  def request_payout(%User{} = creator, amount_cents) do
    if creator.stripe_account_id && creator.stripe_onboarding_complete do
      stripe_post("/v1/payouts", %{amount: amount_cents, currency: "usd"}, stripe_account: creator.stripe_account_id)
    else
      {:error, :onboarding_required}
    end
  end

  def payout_history(%User{} = creator) do
    if creator.stripe_account_id do
      stripe_get("/v1/payouts", stripe_account: creator.stripe_account_id)
    else
      {:ok, %{"data" => []}}
    end
  end

  def verify_webhook(payload, signature) do
    secret = System.get_env("STRIPE_WEBHOOK_SECRET", "")

    if secret == "" or signature == nil do
      Jason.decode(payload)
    else
      timestamp = signature |> String.split(",", trim: true) |> Enum.find_value(fn part ->
        case String.split(part, "=", parts: 2) do
          ["t", value] -> value
          _ -> nil
        end
      end)

      expected =
        :crypto.mac(:hmac, :sha256, secret, "#{timestamp}.#{payload}")
        |> Base.encode16(case: :lower)

      valid? = signature |> String.split(",", trim: true) |> Enum.any?(fn part -> part == "v1=#{expected}" end)

      if valid?, do: Jason.decode(payload), else: {:error, :invalid_signature}
    end
  end

  def handle_webhook(%{"type" => "payment_intent.succeeded", "data" => %{"object" => %{"id" => id}}}), do: confirm_purchase(id)
  def handle_webhook(%{"type" => "account.updated", "data" => %{"object" => %{"id" => id, "details_submitted" => true}}}), do: handle_onboarding_complete(id)
  def handle_webhook(_event), do: :ok

  defp ensure_stripe_account(%User{stripe_account_id: account_id}) when is_binary(account_id) and account_id != "", do: {:ok, account_id}

  defp ensure_stripe_account(%User{} = user) do
    with {:ok, account} <-
           stripe_post("/v1/accounts", %{
             type: "express",
             email: user.payout_email || user.email,
             capabilities: %{card_payments: %{requested: true}, transfers: %{requested: true}}
           }),
         {:ok, updated} <- user |> Ecto.Changeset.change(stripe_account_id: account["id"]) |> Repo.update() do
      {:ok, updated.stripe_account_id}
    end
  end

  defp maybe_transfer_to_creator(%Purchase{} = purchase) do
    purchase = Repo.preload(purchase, course: [:user])
    account = purchase.course.user.stripe_account_id

    if account && purchase.creator_payout_cents > 0 do
      stripe_post("/v1/transfers", %{
        amount: purchase.creator_payout_cents,
        currency: "usd",
        destination: account,
        source_transaction: purchase.stripe_payment_intent_id,
        metadata: %{purchase_id: purchase.id}
      })
    else
      :ok
    end
  end

  defp has_completed_purchase?(user_id, course_id) do
    Repo.exists?(from p in Purchase, where: p.user_id == ^user_id and p.course_id == ^course_id and p.status == "completed")
  end

  defp creator_payout(amount_cents), do: div(amount_cents * (10_000 - @platform_fee_bps), 10_000)
  defp frontend_url, do: System.get_env("FRONTEND_URL", "http://localhost:3000")

  defp stripe_post(path, params, opts \\ []) do
    stripe_request(:post, path, params, opts)
  end

  defp stripe_get(path, opts) do
    stripe_request(:get, path, %{}, opts)
  end

  defp stripe_request(method, path, params, opts) do
    secret = System.get_env("STRIPE_SECRET_KEY", "")

    if secret == "" do
      {:error, :stripe_not_configured}
    else
      headers =
        [{"authorization", "Bearer #{secret}"}, {"content-type", "application/x-www-form-urlencoded"}] ++
          case opts[:stripe_account] do
            nil -> []
            account -> [{"stripe-account", account}]
          end

      body = URI.encode_query(flatten_params(params))
      url = "https://api.stripe.com#{path}"

      request =
        case method do
          :get -> Finch.build(:get, url <> "?" <> body, headers)
          :post -> Finch.build(:post, url, headers, body)
        end

      with {:ok, response} <- Finch.request(request, Learnflow.Finch),
           {:ok, decoded} <- Jason.decode(response.body),
           true <- response.status in 200..299 do
        {:ok, decoded}
      else
        false -> {:error, :stripe_error}
        {:ok, %Finch.Response{} = response} -> {:error, response.body}
        error -> error
      end
    end
  end

  defp flatten_params(params) do
    Enum.flat_map(params, fn {key, value} -> flatten_param(to_string(key), value) end)
  end

  defp flatten_param(key, value) when is_map(value) do
    Enum.flat_map(value, fn {child_key, child_value} -> flatten_param("#{key}[#{child_key}]", child_value) end)
  end

  defp flatten_param(key, value), do: [{key, to_string(value)}]
end
