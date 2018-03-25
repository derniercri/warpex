defmodule Warpex.HTTP do
  alias Warpex.Application
  @moduledoc false

  defp headers(key_type) do
      [
        "X-Warp10-Token": Application.get_key(:write),
        "Content-Type": "text/plain"
      ]
  end

  def get(endpoint) do
    opts = Application.httpoison_opts()
    HTTPoison.get(Application.address() <> endpoint, headers(:read), opts)
    |> handle_response
  end

  def post(endpoint, data) do
    opts = Application.httpoison_opts()
    HTTPoison.post(Application.address() <> endpoint, Poison.encode!(data), headers(:write), opts)
    |> handle_response
  end

  defp handle_response(response) do
    case response do
      {:ok, %HTTPoison.Response{status_code: status_code} = response } when status_code in 200..299 ->
        {:ok, Poison.decode!(response.body) }

      {:ok, %HTTPoison.Response{status_code: status_code} = response } when status_code in 400..599 ->
        {:error, Poison.decode!(response.body) }

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, %{ reason: reason } }
    end
  end

end