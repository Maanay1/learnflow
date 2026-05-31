defmodule LearnflowWeb.CertificateController do
  use LearnflowWeb, :controller
  import Ecto.Query
  alias Learnflow.Dashboard
  alias Learnflow.Dashboard.Certificate
  alias Learnflow.Repo

  def download(conn, %{"id" => id}) do
    user_id = conn.assigns.current_user.id

    case Repo.one(from c in Certificate, where: c.id == ^id and c.user_id == ^user_id) do
      nil ->
        {:error, :not_found}

      certificate ->
        with {:ok, url} <- Dashboard.generate_certificate_pdf(certificate) do
          json(conn, %{download_url: url})
        end
    end
  end
end
