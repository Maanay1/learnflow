defmodule Learnflow.Storage do
  @moduledoc """
  MinIO/S3 storage operations for private JARQ media.
  """

  require Logger

  @default_endpoint "http://minio:9000"
  @upload_ttl_seconds 60 * 60
  @view_ttl_seconds 15 * 60
  @download_ttl_seconds 24 * 60 * 60

  def config do
    endpoint = System.get_env("MINIO_ENDPOINT", @default_endpoint)
    uri = URI.parse(endpoint)

    [
      scheme: "#{uri.scheme || "http"}://",
      host: uri.host || "minio",
      port: uri.port || 9000,
      access_key_id: System.get_env("MINIO_ACCESS_KEY"),
      secret_access_key: System.get_env("MINIO_SECRET_KEY"),
      region: "us-east-1"
    ]
  end

  def public_config do
    endpoint = System.get_env("MINIO_PUBLIC_ENDPOINT", System.get_env("MINIO_ENDPOINT", @default_endpoint))
    uri = URI.parse(endpoint)

    config()
    |> Keyword.merge(scheme: "#{uri.scheme || "http"}://", host: uri.host || "localhost", port: uri.port || 9000)
  end

  def bucket_videos, do: System.get_env("MINIO_BUCKET_VIDEOS", "learnflow-videos")
  def bucket_thumbnails, do: System.get_env("MINIO_BUCKET_THUMBNAILS", "learnflow-thumbnails")
  def bucket_certificates, do: System.get_env("MINIO_BUCKET_CERTIFICATES", "learnflow-certificates")
  def bucket_avatars, do: System.get_env("MINIO_BUCKET_AVATARS", "jarq-avatars")

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
    |> ExAws.request(config())
  end

  def get_object(bucket, key) do
    bucket
    |> ExAws.S3.get_object(key)
    |> ExAws.request(config())
    |> case do
      {:ok, %{body: body}} -> {:ok, body}
      {:ok, body} when is_binary(body) -> {:ok, body}
      {:error, reason} -> {:error, reason}
    end
  end

  def delete_object(bucket, key) do
    bucket
    |> ExAws.S3.delete_object(key)
    |> ExAws.request(config())
  end

  def create_buckets_if_not_exist do
    Enum.each([bucket_videos(), bucket_thumbnails(), bucket_certificates(), bucket_avatars()], fn bucket ->
      bucket
      |> ExAws.S3.put_bucket("us-east-1")
      |> ExAws.request(config())
      |> case do
        {:ok, _} -> :ok
        {:error, {:http_error, 409, _}} -> :ok
        {:error, reason} -> Logger.warning("MinIO bucket setup skipped: #{inspect(reason)}")
      end
    end)

    :ok
  end

  defp presign(method, bucket, key, opts) do
    ExAws.Config.new(:s3, public_config())
    |> ExAws.S3.presigned_url(method, bucket, key, opts)
    |> case do
      {:ok, url} -> {:ok, url}
      {:error, reason} -> {:error, reason}
    end
  rescue
    error -> {:error, error}
  end
end
