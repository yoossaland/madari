defmodule Madari.Release do
  @app :madari

  def migrate do
    ensure_started()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    ensure_started()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp ensure_started do
    Application.ensure_all_started(:ssl)
  end

  def user_create do
    Application.load(@app)

    {:ok, _, _} =
      Ecto.Migrator.with_repo(Madari.Repo, fn _repo ->
        email =
          IO.gets("Email: ")
          |> String.trim()

        password =
          IO.gets("Password: ")
          |> String.trim()

        Madari.Repo.insert!(%Madari.Accounts.User{
          email: email,
          hashed_password: Argon2.hash_pwd_salt(password)
        })
      end)
  end
end
