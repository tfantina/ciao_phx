import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# Start the phoenix server if environment is set and running in a release
if System.get_env("PHX_SERVER") && System.get_env("RELEASE_NAME") do
  config :ciao, CiaoWeb.Endpoint, server: true
end

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

  config :ciao, Ciao.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "https://ciaoplace.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :ciao, CiaoWeb.Endpoint,
    url: [host: host, port: 443],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base,
    check_origin: ["https://ciaoplace.com"]

  config :ex_aws, :s3,
    scheme: "https://",
    host: System.get_env("S3_URL"),
    region: System.get_env("S3_REGION")

  config :ciao, Ciao.Images.ProfilePics,
    provider: Ciao.Storage.S3Provider,
    region: System.get_env("S3_REGION"),
    bucket: System.get_env("S3_BUCKET"),
    access_key_id: System.get_env("S3_ACCESS_KEY"),
    secrtet_access_key: System.get_env("S3_SECRET_KEY")

  config :ciao, Ciao.Images.PostImages,
    provider: Ciao.Storage.S3Provider,
    region: System.get_env("S3_REGION"),
    bucket: System.get_env("S3_BUCKET"),
    access_key_id: System.get_env("S3_ACCESS_KEY"),
    secrtet_access_key: System.get_env("S3_SECRET_KEY")

  config :ciao, Ciao.Images.PlaceImages,
    provider: Ciao.Storage.S3Provider,
    region: System.get_env("S3_REGION"),
    bucket: System.get_env("S3_BUCKET"),
    access_key_id: System.get_env("S3_ACCESS_KEY"),
    secrtet_access_key: System.get_env("S3_SECRET_KEY")

  config :ciao, Config.URL, root_url: "https://ciaoplace.com"


config :ciao, Ciao.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: System.get_env("SENDGRID_KEY")

config :swoosh, :api_client, Swoosh.ApiClient.Hackney
end
