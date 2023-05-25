defmodule CiaoWeb.UserSettingsView do
  @moduledoc false
  use CiaoWeb, :view

  def form_label(%{login_preference: "password"}), do: label("password")
  def form_label(_), do: "email"
end
