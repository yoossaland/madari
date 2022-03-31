defmodule Madari.Api.Sysctl do
  use Rustler,
    otp_app: :madari,
    crate: :madari_api_sysctl

  # When loading a NIF module, dummy clauses for all NIF function are required.
  # NIF dummies usually just error out when called when the NIF is not loaded, as that should never normally happen.
  def read(_oid), do: :erlang.nif_error(:nif_not_loaded)
  def boottime(), do: :erlang.nif_error(:nif_not_loaded)
end
