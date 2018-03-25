defmodule Warpex.MixProject do
  use Mix.Project

  def project do
    [
      app: :warpex,
      version: "0.1.0",
      elixir: "~> 1.6",
      description: "Wrap10 client",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :httpoison],
      mod: {Warpex.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.0"},
    ]
  end

  defp package do
    [ # These are the default files included in the package
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Guillaume Bailleul<laibulle@gmail.com>"],
      licenses: ["MIT"],
      links: %{ "GitHub" => "https://github.com/derniercri/warpex", "DernierCri" => "https://derniercri.io/" }
    ]
  end
end
