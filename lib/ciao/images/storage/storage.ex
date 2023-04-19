defmodule Ciao.Storage do
  @moduledoc false
  alias Ciao.Storage.Provider

  @doc false
  defmacro __using__(opts \\ []) do
    otp_app = Keyword.fetch!(opts, :otp_app)
    module = __CALLER__.module
    env_config = Application.get_env(otp_app, module, [])

    provider =
      case Keyword.get(opts, :provider) || Keyword.get(env_config, :provider) do
        module when is_atom(module) ->
          module

        _ ->
          raise """
            :provider is missing from the storage config, please set a provider
          """
      end

    quote do
      @behaviour Ciao.Storage
      @config unquote(provider).init(unquote(env_config))

      @doc false
      def config,
        do: unquote(provider).init(Application.get_env(unquote(otp_app), __MODULE__, []))

      @doc false
      def provider, do: unquote(provider)

      @impl true
      def url(key, opts \\ []), do: provider().url(config(), key)

      @impl true
      def delete(key), do: provider().delete(config(), key)

      @impl true
      def upload(key, io, opts \\ []), do: provider().upload(config(), key, io, opts)

      @impl true
      def download(key), do: provider().download(config(), key)

      @impl true
      def exists?(key), do: provider().exists?(config(), key)
    end
  end

  @doc false
  @callback url(key :: String.t(), opts :: Keyword.t()) ::
              {:ok, Provider.file_url_t()} | {:error, any()}

  @doc false
  @callback upload(key :: String.t(), io :: iodata(), opts :: Keyword.t()) ::
              :ok | {:error, any()}

  @doc false
  @callback download(key :: String.t()) :: {:ok, any()} | {:error, any()}

  @doc false
  @callback delete(key :: String.t()) :: :ok | {:error, any()}

  @doc false
  @callback exists?(key :: String.t()) :: boolean()
end
