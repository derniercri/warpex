defmodule Warpex.HTTP do

  @moduledoc false

  def get(endpoint) do
    headers = ["Authorization": Warpex.get_key(:read)]
    opts = Warpex.httpoison_opts()
    HTTPoison.get(Warpex.get_key(:address) <> endpoint, Keyword.merge(@headers, headers), opts)
    |> handle_response
  end

  #def post(endpoint, data, key_type \\ :write) do
  #  headers = ["Authorization": Keenex.get_key(key_type)]
  #  opts = Keenex.httpoison_opts()
  #  HTTPoison.post(@url <> endpoint, Poison.encode!(data), Keyword.merge(@headers, headers), opts)
  #  |> handle_response
  #end

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