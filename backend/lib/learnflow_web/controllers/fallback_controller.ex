defmodule LearnflowWeb.FallbackController do
  use LearnflowWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    {field, messages} = changeset |> errors() |> Enum.at(0, {:base, ["invalid"]})

    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: List.first(messages), field: to_string(field)})
  end

  def call(conn, {:error, :not_found}), do: conn |> put_status(:not_found) |> json(%{error: "not_found"})
  def call(conn, {:error, :creator_required}), do: conn |> put_status(:forbidden) |> json(%{error: "creator_required"})
  def call(conn, {:error, :video_unavailable}), do: conn |> put_status(:forbidden) |> json(%{error: "video_unavailable"})
  def call(conn, {:error, :unauthorized}), do: conn |> put_status(:forbidden) |> json(%{error: "unauthorized"})
  def call(conn, {:error, reason}), do: conn |> put_status(:bad_request) |> json(%{error: reason})

  defp errors(changeset), do: Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
end
