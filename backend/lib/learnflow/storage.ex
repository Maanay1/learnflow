defmodule Learnflow.Storage do
  @moduledoc """
  MinIO/S3 storage operations for private JARQ media.
  """

  require Logger

  @default_endpoint "http://minio:9000"
  @upload_ttl_seconds 60 * 60
  @view_ttl_seconds 15 * 60
  @download_ttl_seconds 24 * 60 * 60
  @required_env_vars ~w(MINIO_ENDPOINT MINIO_PUBLIC_ENDPOINT MINIO_ACCESS_KEY MINIO_SECRET_KEY)

  def config do
    endpoint = System.get_env("MINIO_ENDPOINT", @default_endpoint)
    uri = URI.parse(endpoint)

    [
      scheme: "#{uri.scheme || "http"}://",
      host: uri.host || "minio",
      port: uri.port || 9000,
      access_key_id: System.get_env("MINIO_ACCESS_KEY"),
      secret_access_key: System.get_env("MINIO_SECRET_KEY"),
      region: storage_region(endpoint)
    ]
  end

  def public_config do
    endpoint = System.get_env("MINIO_PUBLIC_ENDPOINT", System.get_env("MINIO_ENDPOINT", @default_endpoint))
    uri = URI.parse(endpoint)

    config()
    |> Keyword.merge(
      scheme: "#{uri.scheme || "http"}://",
      host: uri.host || "localhost",
      port: uri.port || 9000,
      region: storage_region(endpoint)
    )
  end

  def bucket_videos, do: System.get_env("MINIO_BUCKET_VIDEOS", "learnflow-videos")
  def bucket_thumbnails, do: System.get_env("MINIO_BUCKET_THUMBNAILS", "learnflow-thumbnails")
  def bucket_certificates, do: System.get_env("MINIO_BUCKET_CERTIFICATES", "learnflow-certificates")
  def bucket_avatars, do: System.get_env("MINIO_BUCKET_AVATARS", "jarq-avatars")

  def validate_configuration do
    missing = Enum.filter(@required_env_vars, &(System.get_env(&1) in [nil, ""]))

    if missing == [] do
      :ok
    else
      {:error, {:storage_not_configured, missing}}
    end
  end

  def generate_upload_url(bucket, key, content_type, _max_bytes) do
    opts = [
      expires_in: @upload_ttl_seconds,
      headers: [
        {"content-type", content_type}
      ]
    ]

    presign(:put, bucket, key, opts)
  end

  def generate_view_url(bucket, key, user_id, session_id) do
    opts = [
      expires_in: @view_ttl_seconds,
      query_params: [
        {"x-user-id", to_string(user_id)},
        {"x-session-id", to_string(session_id)}
      ]
    ]

    presign(:get, bucket, key, opts)
  end

  def generate_read_url(bucket, key) do
    presign(:get, bucket, key, expires_in: @view_ttl_seconds)
  end

  def generate_download_url(bucket, key, filename) do
    opts = [
      expires_in: @download_ttl_seconds,
      query_params: [
        {"response-content-disposition", "attachment; filename=\"#{filename}\""}
      ]
    ]

    presign(:get, bucket, key, opts)
  end

  def put_object(bucket, key, body, content_type) do
    bucket
    |> ExAws.S3.put_object(key, body, content_type: content_type)
    |> request()
  end

  def get_object(bucket, key) do
    bucket
    |> ExAws.S3.get_object(key)
    |> request()
    |> case do
      {:ok, %{body: body}} -> {:ok, body}
      {:ok, body} when is_binary(body) -> {:ok, body}
      {:error, reason} -> {:error, reason}
    end
  end

  def delete_object(bucket, key) do
    bucket
    |> ExAws.S3.delete_object(key)
    |> request()
  end

  def create_buckets_if_not_exist do
    case validate_configuration() do
      :ok ->
        if r2_endpoint?(System.get_env("MINIO_ENDPOINT", @default_endpoint)) do
          Logger.info("R2 bucket setup skipped: buckets are managed in Cloudflare")
        else
          Enum.each([bucket_videos(), bucket_thumbnails(), bucket_certificates(), bucket_avatars()], fn bucket ->
            bucket
            |> ExAws.S3.put_bucket(storage_region(System.get_env("MINIO_ENDPOINT", @default_endpoint)))
            |> request()
            |> case do
              {:ok, _} -> :ok
              {:error, {:http_error, 409, _}} -> :ok
              {:error, reason} -> Logger.warning("MinIO bucket setup skipped: #{inspect(reason)}")
            end
          end)
        end

      {:error, {:storage_not_configured, missing}} ->
        Logger.warning("MinIO bucket setup skipped: missing #{Enum.join(missing, ", ")}")
    end

    :ok
  end

  defp presign(method, bucket, key, opts) do
    with :ok <- validate_configuration() do
      ExAws.Config.new(:s3, public_config())
      |> ExAws.S3.presigned_url(method, bucket, key, opts)
      |> case do
        {:ok, url} -> {:ok, url}
        {:error, reason} -> {:error, reason}
      end
    end
  rescue
    error -> {:error, error}
  end

  defp request(operation) do
    with :ok <- validate_configuration() do
      ExAws.request(operation, config())
    end
  end

  defp storage_region(endpoint) do
    System.get_env("MINIO_REGION") ||
      if(r2_endpoint?(endpoint), do: "auto", else: "us-east-1")
  end

  defp r2_endpoint?(endpoint) do
    endpoint
    |> URI.parse()
    |> Map.get(:host, "")
    |> to_string()
    |> String.ends_with?(".r2.cloudflarestorage.com")
  end
end
