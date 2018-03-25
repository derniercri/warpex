# Warpex

Warpex is a Warp10 client for Elixir. It is a __work in progress__, use it at your own risk.

## Usage

Add it to your applications and dependencies in `mix.exs`:

```elixir
def application do
  [applications: [:warpex]]
end
  
def deps do
  [{:warpex, "~> 1.1"}]
end
```


Configure it in `config.exs`:

```elixir
config :warpex,
  address: "http://localhost",  # defaults to System.get_env("WARP10_ADDRESS"),
  read_key:   "xxxxx",  # defaults to System.get_env("WARP10_READ_KEY")
  write_key:  "xxxxx",  # defaults to System.get_env("WARP10_WRITE_KEY")
  httpoison_opts: [timeout: 5000]  # defaults to []
```

And then call functions like:

```elixir
{status, response} = Warpex.update(
    [%{
        "labels" => "label1=anything,label2=anotherthing", 
        "name" => "metric.1.memory_available", 
        "val" => 12, 
        "ts" => 1521969018754000
    }])
```


```elixir
{status, response} = Warpex.fetch("~metric.1.*{}", start, stop)
```

`status` is either `:ok` or `:error`.

`response` is the raw response from Warp10 as text