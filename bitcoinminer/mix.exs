defmodule Bitcoinminer.Mixfile do
  use Mix.Project

  def project do
    [
      app: :bitcoinminer,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      escript: [main_module: Bitcoinminer, emu_args: ["-name muginu@10.136.105.250 -setcookie monster"]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Bitcoinminer, []},
      env: [cookie: 'monster']
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
