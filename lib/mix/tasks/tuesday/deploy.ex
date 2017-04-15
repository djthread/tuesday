defmodule Mix.Tasks.Tuesday.Deploy do
  @shortdoc "Do deploy"

  @moduledoc """
  Kick off the deploy script

      mix tuesday.deploy

  """

  use Mix.Task

  def run(_) do
    Mix.shell.info "Calling deploy.sh..."

    do_run("assets/deploy.sh")
  end

  defp do_run(cmdStr) when is_binary(cmdStr) do
    cmd = Mix.shell.cmd cmdStr

    case cmd do
      0 ->
        :ok
      exit_code ->
        Mix.raise "Test suite failed (during " <>
          cmdStr <> ") with exit code: #{inspect exit_code}"
    end
  end
end
