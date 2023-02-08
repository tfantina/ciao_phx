defmodule Ciao.Storage.Provider do
  @moduledoc false
  @type ok_t :: {:ok, any()}
  @type error_t :: {:error, any()}
  @type config_t :: map()
  @type file_url_t :: {:local | :remote, String.t()}

  @doc false
  @callback init(opts :: Keyword.t()) :: config_t()

  @doc false
  @callback url(config :: config_t(), key :: String.t(), opts :: Keyword.t()) ::
              {:ok, file_url_t()} | error_t()

  @doc false
  @callback upload(config :: config_t(), key :: String.t(), io :: iodata(), opts :: Keyword.t()) ::
              {:ok, UUID.t()} | error_t()

  @doc false
  @callback download(config :: config_t(), key :: String.t()) :: ok_t() | error_t()

  @doc false
  @callback delete(config_t :: config_t(), key :: String.t()) :: :ok | error_t()

  @doc false
  @callback exists?(config_t :: config_t(), key :: String.t()) :: boolean()
end
