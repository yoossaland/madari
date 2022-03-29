defmodule Yoossa.ConfigUtil do
  import Toml

  def auto_load_config!() do
    path = "yoossa.toml"

    if File.exists?(path) do
      Toml.decode_file!(path)
    else
      path = "/yoossa/yoossa.toml"

      if File.exists?(path) do
        Toml.decode_file!(path)
      else
        raise "Configuration file 'yoossa.toml' not found in current directory or at /yoossa/yoossa.toml"
      end
    end
  end
end
