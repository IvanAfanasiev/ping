defmodule Ping.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :ping,
    module: Ping.Auth.Guardian,
    error_handler: Ping.Auth.ErrorHandler

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
