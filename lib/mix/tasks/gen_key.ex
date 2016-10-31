defmodule Mix.Tasks.GenKey do
  @moduledoc """
  Generate encryption key for Guardian
  """

  @keyfile Application.get_env(:tuesday, :auth_keyfile)

  @doc "Create key file"
  def run(_) do
    binary =
      JOSE.JWS.generate_key(%{"alg" => "HS512"})
      |> :erlang.term_to_binary

    File.write!(@keyfile, binary)

    IO.puts "Wrote #{@keyfile}"
  end
end
