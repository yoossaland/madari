defmodule Madari.ConfigUtil do
  import Toml

  def auto_load_config!() do
    path = "madari.toml"

    if File.exists?(path) do
      Toml.decode_file!(path)
    else
      path = "/madari/madari.toml"

      if File.exists?(path) do
        Toml.decode_file!(path)
      else
        raise "Configuration file 'madari.toml' not found in current directory or at /madari/madari.toml"
      end
    end
  end
end
