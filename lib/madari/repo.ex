defmodule Madari.Repo do
  use Ecto.Repo,
    otp_app: :madari,
    adapter: Ecto.Adapters.SQLite3
end
