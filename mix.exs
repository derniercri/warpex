defmodule Warpex.MixProject do
  use Mix.Project

  @version "1.1.0"

  def project do
    [
      app: :warpex,
      version: @version,
      elixir: "~> 1.6",
      description: "Wrap10 client",
      package: package(),
      docs: docs(),
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
      {:ex_doc, "~> 0.16", only: :dev}
    ]
  end

  def docs do
    [
      extras: ["README.md", "CHANGELOG.md"],
      source_ref: "v#{@version}"
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
