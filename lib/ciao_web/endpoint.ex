defmodule CiaoWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :ciao

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_ciao_key",
    signing_salt: "JdTADKnE"
  ]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug(Plug.Static,
    at: "/",
    from: :ciao,
    gzip: false,
    only: ~w(assets fonts images favicon.ico robots.txt)
  )

  socket("/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]])

  image_file_storage = Application.get_env(:ciao, Ciao.Images.PostImages)
  place_file_storage = Application.get_env(:ciao, Ciao.Images.PlaceImages)

  if Keyword.fetch!(image_file_storage, :provider) == Ciao.Storage.LocalProvider do
    plug Plug.Static,
      at: "/pics",
      from: {:ciao, Keyword.fetch!(image_file_storage, :relative)},
      gzip: false
  end

  if Keyword.fetch!(place_file_storage, :provider) == Ciao.Storage.LocalProvider do
    plug Plug.Static,
      at: "/pics",
      from: {:ciao, Keyword.fetch!(place_file_storage, :relative)},
      gzip: false
  end

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
    plug(Phoenix.Ecto.CheckRepoStatus, otp_app: :ciao)
  end

  plug(Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"
  )

  plug(Plug.RequestId)
  plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)
  plug(Plug.Session, @session_options)
  plug(CiaoWeb.Router)
end
