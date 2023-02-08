defmodule Ciao.Storage.S3Provider do
  @moduledoc false
  alias ExAws.S3
  alias Ciao.Storage.Provider
  import Ciao

  require Logger

  @behaviour Provider

  @impl true
  def init(opts \\ []) do
    Enum.into(opts, %{}, & &1)
  end

  @impl true
  def url(%{bucket: bucket} = config, key, opts \\ []) do
    Logger.info(label: "OK?")

    if Keyword.get(opts, :static_url, false) do
      "https://ciaoplace.com/images"
      |> Path.join(key)
      |> ok()
    else
      config
      |> s3_config()
      |> S3.presigned_url(:get, bucket, key, opts)
      |> case do
        {:ok, url} -> ok({:remote, url})
        {:error, _} = err -> err
      end
    end
  end

  @impl true
  def upload(%{bucket: bucket} = config, key, io, opts \\ []) do
    bucket
    |> S3.put_object(key, io, opts)
    |> ex_aws_request(config, opts)
    |> case do
      {:ok, _} -> {:ok, key}
      {:error, _} = err -> err
    end
  end

  @impl true
  def download(%{bucket: bucket} = config, key) do
    if exists?(config, key) do
      bucket
      |> S3.get_object(key)
      |> ex_aws_request(config)
      |> case do
        {:ok, %{body: body}} -> ok(body)
        {:error, _} = err -> err
      end
    else
      error(:enoent)
    end
  end

  @impl true
  def delete(%{bucket: bucket} = config, key) do
    bucket
    |> S3.delete_object(key)
    |> ex_aws_request(config)
    |> case do
      {:ok, _} -> :ok
      {:error, _} = err -> err
    end
  end

  @impl true
  def exists?(%{bucket: bucket} = config, key) do
    bucket
    |> S3.head_object(key)
    |> ExAws.request(config)
    |> case do
      {:ok, _} -> true
      _ -> false
    end
  end

  defp ex_aws_request(op, config, explicit_overrides \\ []) do
    overrides =
      config
      |> Map.take([:region, :access_key_id, :secret_access_key])
      |> Enum.into([])
      |> Keyword.merge(explicit_overrides)

    ExAws.request(op, overrides)
  end

  defp s3_config(config) do
    config = Map.take(config, [:region, :access_key_id, :secret_access_key])

    ExAws.Config.new(:s3, config)
  end
end
