# https://elixir-lang.org/getting-started/mix-otp/supervisor-and-application.html

defmodule KV.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      # KV.Registry.start_link(KV.Registry)
      worker(KV.Registry, [KV.Registry])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
