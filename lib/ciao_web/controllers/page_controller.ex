defmodule CiaoWeb.PageController do
  use CiaoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
