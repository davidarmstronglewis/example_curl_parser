defmodule CurlParser do
  @moduledoc """
  Documentation for `CurlParser`.
  """

  defmodule CurlCommand do
    defstruct url: nil, method: nil, headers: []

    @type url :: String.t()
    @type method :: :get | :post | :put | :patch | :delete | :head
    @type headers ::
            list({
              String.t(),
              String.t() | list(String.t())
            })
    @type body :: binary()
  end

  @doc """
  Parses a `curl` command.

  ## Examples

      iex> CurlParser.parse("curl -X www.google.com")
      %CurlCommand{url: "www.google.com", method: :get, headers: []}

  """
  def parse(command), do: do_parse(String.split(command), %CurlCommand{})

  defp do_parse(command_parts, %CurlCommand{} = curl_command)
       when is_list(command_parts) do
    case command_parts do
      ["curl" | rest] ->
        do_parse(rest, curl_command)

      ["-X", method | rest]
      when method in ["GET", "POST", "PUT", "PATCH", "DELETE", "HEAD"] ->
        do_parse(rest, %{
          curl_command
          | method: method |> String.downcase() |> String.to_existing_atom()
        })

      ["-X" | rest] ->
        do_parse(rest, %{curl_command | method: :get})

      [url | [] = rest] ->
        do_parse(rest, %{curl_command | url: url})

      [] ->
        # TODO: Validate?
        curl_command
    end
  end
end
