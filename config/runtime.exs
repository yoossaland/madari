import Config
import IP
import Yoossa.ConfigUtil

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

conf = Yoossa.ConfigUtil.auto_load_config!()

config :yoossa, YoossaWeb.Endpoint, server: true

%{"app" => %{"data_path_prefix" => data_path_prefix}} = conf

%{"database" => %{"url" => database_url, "pool_size" => pool_size}} = conf

database_path = Path.join(data_path_prefix, database_url)

config :yoossa, Yoossa.Repo,
  database: database_path,
  pool_size: pool_size

# The secret key base is used to sign/encrypt cookies and other secrets.
%{"phoenix" => %{"secret_key_base" => secret_key_base}} = conf

if String.starts_with?(secret_key_base, "CHANGE") do
  raise "Please update yoossa.toml with a secret key."
end

%{
  "https" => %{
    "port" => https_port,
    "bind" => https_bind,
    "host" => https_host,
    "keyfile" => https_keyfile,
    "certfile" => https_certfile
  }
} = conf

https_ip = IP.from_string!(https_bind)

config :yoossa, YoossaWeb.Endpoint,
  url: [
    host: https_host,
    port: https_port
  ],
  https: [
    ip: https_ip,
    port: https_port,
    cipher_suite: :strong,
    keyfile: Path.join(data_path_prefix, https_keyfile),
    certfile: Path.join(data_path_prefix, https_certfile)
  ],
  secret_key_base: secret_key_base
