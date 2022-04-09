defmodule Madari.Api.Preference do
  alias Madari.Api.Sysrc

  @config %{
    "default_bootenv": %{
      label: "Default Boot Environment",
      help: "Automatically set BE for next boot on successful boot",
      default: "default",
      override: "fresh-install",
      choices: ["default", "madari-0.0.1", "fresh-install"],
      icon: "clock-rotate-left"
    },
    "pushover_user_key": %{
      label: "Pushover User Key",
      help: "User Key for push notifications via https://pushover.net",
      default: "",
      override: "",
      choices: [],
    },
    "pushover_api_key": %{
      label: "Pushover API Key",
      help: "API Key for push notifications via https://pushover.net",
      default: "",
      override: "",
      choices: [],
    },
    "backup_b2_bucket": %{
      label: "Backblaze B2 Bucket",
      help: "Backblaze B2 Bucket to store encrypted, deduplicated, remote backups",
      default: "",
      override: "",
      choices: [],
    },
    "backup_b2_app_id": %{
      label: "Backblaze B2 App ID",
      help: "Backblaze App ID for https://backblaze.com/b2 with permissions to read backup_b2_bucket",
      default: "",
      override: "",
      choices: [],
    },
    "backup_b2_app_key": %{
      label: "Backblaze B2 App Key",
      help: "Backblaze App Key for https://backblaze.com/b2 with permissions to read backup_b2_bucket",
      default: "",
      override: "",
      choices: [],
    },
    "backup_password": %{
      label: "Backup password",
      help: "Use a password generator / manager for at least 32 char long password",
      default: "",
      override: "",
      choices: [],
    },
    "backup_schedule": %{
      label: "Backup schedule",
      help: "Choose a schedule for backups",
      default: "daily",
      override: "",
      choices: ["hourly", "every 3 hours", "every 6 hours", "every 12 hours", "daily", "weekly", "monthly"]
    },
    "backup_enable": %{
      label: "Backup enable",
      help: "Enable backup and restore functions",
      default: "NO",
      override: "",
      choices: ["YES", "NO"],
    },
    "backup_bootenv_enable": %{
      label: "Backup boot environments",
      help: "Enable backup and restore for boot environments",
      default: "NO",
      override: "",
      choices: ["YES", "NO"],
    },
    "backup_madari_enable": %{
      label: "Backup Madari",
      help: "Enable backup and restore for Madari's installation dataset: config + binaries",
      default: "NO",
      override: "",
      choices: ["YES", "NO"],
    },
    "backup_userdata_enable": %{
      label: "Backup user data",
      help: "Enable backup and restore for home directory and other configured datasets",
      default: "NO",
      override: "",
      choices: ["YES", "NO"],
    },
  }

  def all() do
    # Sysrc.all() |> IO.inspect()
    # Sysrc.all("/madari/madari.conf") |> IO.inspect()
    @config
  end
  # def descriptions_map() do
  #   # Sysrc.descriptions_map() |> IO.inspect()
  #   Sysrc.descriptions_map("/madari/madari.conf") |> IO.inspect()
  # end
  def get(key) do
    Sysrc.read(key, "/madari/madari.conf")
  end

  def set(key, value) do
    Sysrc.write(key, value, "/madari/madari.conf")
  end
end
