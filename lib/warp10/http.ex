defmodule Warpex.HTTP do
  alias Warpex.Application
  @moduledoc false

  alias Warpex.HTTP

  use HTTPoison.Base

  def process_url(url), do: Application.address() <> url

  def map_to_text(data) do
    Enum.reduce(data, "", &"#{&2}\n#{transform_item(&1)}")
  end

  def transform_item(item) do
    item
    |> Map.put_new("latlon", "")
    |> Map.put_new("elev", "")
    |> (fn i ->
          "#{i["ts"]}/#{i["latlon"]}/#{i["elev"]} " <> "#{i["name"]}{#{i["labels"]}} #{i["val"]}"
        end).()
  end

  defp headers(key_type) do
    [
      "X-Warp10-Token": Application.get_key(key_type),
      "Content-Type": "text/plain"
    ]
  end

  def get(endpoint, params) do
    opts = Application.httpoison_opts()
    opts = [{:params, params} | opts]

    endpoint
    |> HTTP.get(headers(:read), opts)
    |> handle_response()
  end

  def post(endpoint, data) do
    IO.inspect "DEBUG WARPEX"
    IO.inspect data
    opts = Application.httpoison_opts()

    endpoint
    |> HTTP.post(data, headers(:write), opts)
    |> handle_response()
  end

  defp handle_response(response) do
    case response do
      {:ok, %HTTPoison.Response{status_code: status_code} = response}
      when status_code in 200..299 ->
        {:ok, response.body}

      {:ok, %HTTPoison.Response{status_code: status_code} = response}
      when status_code in 400..599 ->
        {:error, response.body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, %{reason: reason}}
    end
  end

  def parse_response(_previous, [], data) do
    Enum.reverse(data)
  end

  def parse_response(previous, ["" | tail], data) do
    parse_response(previous, tail, data)
  end

  def parse_response(previous, [head | tail], data) do
    head
    |> parse_row()
    |> fill_current(previous)
    |> (&parse_response(&1, tail, [&1 | data])).()
  end

  defp fill(current, previous, key) do
    case current[key] do
      "" ->
        current
        |> Map.put(key, previous[key])

      nil ->
        current
        |> Map.put(key, previous[key])

      _ ->
        current
    end
  end

  defp fill_current(current, previous) do
    current
    |> fill(previous, "latlon")
    |> fill(previous, "elev")
    |> fill(previous, "labels")
    |> fill(previous, "name")
  end

  defp parse_row(data) do
    [headers, name, value] =
      case String.split(data, " ") do
        [_headers, _name, _value] = data -> data
        [headers, value] -> [headers, nil, value]
      end

    parsed_map =
      Map.merge(
        %{"value" => value},
        parse_header(headers)
      )

    Map.merge(
      parsed_map,
      parse_name(name)
    )
  end

  defp parse_header(header) do
    [ts, latlon, elev] = String.split(String.replace(header, "=", ""), "/")

    %{
      "ts" => elem(Integer.parse(ts), 0),
      "latlon" => latlon,
      "elev" => elev
    }
  end

  defp parse_name(nil) do
    %{"name" => nil, "labels" => nil}
  end

  defp parse_name(name) do
    [name, rest] = String.split(name, "{")
    [labels_text, _] = String.split(rest, "}")

    labels =
      labels_text
      |> String.split(",")
      |> parse_labels(%{})

    %{"name" => name, "labels" => labels}
  end

  defp parse_labels([h | t], labels) do
    [key, value] = String.split(h, "=")
    labels = Map.put(labels, key, value)
    parse_labels(t, labels)
  end

  defp parse_labels([], labels) do
    labels
  end
end
