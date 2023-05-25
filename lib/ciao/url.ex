defmodule Ciao.URL do
  @moduledoc "Builds urls for various functions"
  @truval "B5BEA41B6C623F7"
  @falval "FCBCF165908DD1"

  @spec build_invite_url(String.t()) :: String.t()
  def build_invite_url(token) do
    root = CiaoWeb.Endpoint.url()
    root <> "/users/invite/#{token}"
  end

  @spec build_magic_url(String.t(), string) :: String.t()
  def build_magic_url(token, remember) do
    root = CiaoWeb.Endpoint.url()
    root <> "/users/sign_in/#{token}-#{remember(remember)}"
  end

  defp remember("true"), do: @truval
  defp remember("false"), do: @falval

  @spec get_remember_token(String.t()) :: tuple()
  def get_remember_token(token_str) do
    case String.split(token_str, "-") do
      [token, remember] ->
        {token, decode_remember(remember)}

      [token] ->
        {token, "false"}
    end
  end

  defp decode_remember(remember), do: if(remember == @truval, do: "true", else: "false")
end
