import Config

config :ping, Ping.Repo,
	username: System.get_env("PGUSER"),
	password: System.get_env("PGPASSWORD"),
	hostname: System.get_env("PGHOST"),
	database: System.get_env("PGDATABASE"),
	show_sensitive_data_on_connection_error: true,
	pool_size: 10,
  socket_options: [:inet6]

config :ping, PingWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: true,
  watchers: [],
  secret_key_base: System.get_env("SECRET_KEY_BASE")

config :ping, Ping.Mailer, adapter: Swoosh.Adapters.Local
# config :swoosh, :api_client, Swoosh.ApiClient.Hackney
config :logger, :console, format: "[$level] $message\n"
config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime
