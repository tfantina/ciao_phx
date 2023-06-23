defmodule CiaoWeb.FlashHelpers do
  @moduledoc false

  use Phoenix.Component

  def flash_msg(%{flash: flash} = assigns) when map_size(flash) == 0 do
    IO.inspect(assigns, label: "SHOPULD MATCH")
    ~H""
  end

  def flash_msg(assigns) do
    IO.inspect(assigns)

    ~H"""
    <div class="alert">
        <%= show_flash(@flash, :success) %>
        <%= show_flash(@flash, :info) %>
        <%= show_flash(@flash, :error) %>
    </div>
    """
  end

  defp show_flash(flash, key) do
    assigns = %{}

    if Map.has_key?(flash, Atom.to_string(key)) do
      ~H"""
      <p class={"alert-#{key}"} role="alert" 
              phx-click="lv:clear-flash"
              phx-value-key={key}>
          <%= live_flash(flash, key) %>
      </p>
      """
    end
  end
end
