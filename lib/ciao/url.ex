defmodule Ciao.URL do
  @moduledoc "Builds urls for various functions"

  @spec build_invite_url(String.t()) :: String.t()
  def build_invite_url(token) do
    root = CiaoWeb.Endpoint.url()
    root <> "/users/invite/#{token}"
  end
end
