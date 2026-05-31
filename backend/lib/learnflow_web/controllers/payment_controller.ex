defmodule LearnflowWeb.PaymentController do
  use LearnflowWeb, :controller
  alias Learnflow.{Dashboard, Payments}

  def access(conn, %{"id" => id}) do
    case Dashboard.get_course_by_id(id) do
      nil -> {:error, :not_found}
      course -> json(conn, Payments.course_access(conn.assigns.current_user, course))
    end
  end

  def purchase(conn, %{"id" => id}) do
    with course when not is_nil(course) <- Dashboard.get_course_by_id(id),
         {:ok, result} <- Payments.create_payment_intent(conn.assigns.current_user, course) do
      json(conn, %{client_secret: result.client_secret})
    else
      nil -> {:error, :not_found}
      {:error, reason} -> conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(reason)})
    end
  end

  def onboarding(conn, _params) do
    with {:ok, url} <- Payments.onboard_creator(conn.assigns.current_user) do
      json(conn, %{url: url})
    end
  end

  def stats(conn, _params), do: json(conn, Payments.get_creator_stats(conn.assigns.current_user))

  def payouts(conn, _params) do
    case Payments.payout_history(conn.assigns.current_user) do
      {:ok, data} -> json(conn, %{payouts: data["data"] || []})
      {:error, reason} -> conn |> put_status(:unprocessable_entity) |> json(%{error: inspect(reason)})
    end
  end

  def webhook(conn, params) do
    payload = Jason.encode!(params)
    signature = conn |> get_req_header("stripe-signature") |> List.first()

    with {:ok, event} <- Payments.verify_webhook(payload, signature) do
      Payments.handle_webhook(event)
      json(conn, %{received: true})
    else
      _ -> conn |> put_status(:bad_request) |> json(%{error: "invalid_signature"})
    end
  end
end
