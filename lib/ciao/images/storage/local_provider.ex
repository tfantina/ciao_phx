defmodule Ciao.Storage.LocalProvider do
  @moduledoc false
  alias Ciao.Storage.Provider

  import Ciao
  require Logger

  @behaviour Provider
  @impl true
  def init(opts \\ []) do
    root = Keyword.fetch!(opts, :root)
    url_prefix = Keyword.get(opts, :url_prefix, root)
    File.mkdir_p!(root)

    %{root: root, url_prefix: url_prefix}
  end

  @impl true
  def url(%{url_prefix: url_prefix}, key, _opts \\ []) do
    case validate_key(key) do
      :ok ->
        ok({:local, Path.join(url_prefix, key)})

      _ ->
        {:local, "/"}
    end
  end

  @impl true
  def upload(%{root: root}, key, io, opts \\ []) do
    with :ok <- validate_key(key),
         path <- Path.join(root, key),
         dir <- Path.dirname(path),
         :ok <- File.mkdir_p(dir),
         :ok <- File.write!(path, io, opts) do
      {:ok, key}
    else
      {:error, _} = error -> error
      res -> {:error, res}
    end
  end

  @impl true
  def download(%{root: root}, key) do
    with :ok <- validate_key(key) do
      root
      |> Path.join(key)
      |> File.read()
    end
  end

  @impl true
  def delete(%{root: root}, key) do
    with :ok <- validate_key(key) do
      root
      |> Path.join(key)
      |> File.rm()
    end
  end

  @impl true
  def exists?(%{root: root}, key) do
    case validate_key(key) do
      :ok ->
        root
        |> Path.join(key)
        |> File.exists?()

      _ ->
        false
    end
  end

  def validate_key(key) do
    if unsafe_name?(key), do: error(:invalid_key), else: :ok
  end
end
