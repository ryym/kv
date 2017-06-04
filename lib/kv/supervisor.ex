# https://elixir-lang.org/getting-started/mix-otp/supervisor-and-application.html

defmodule KV.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      # KV.Registry.start_link(KV.Registry)
      worker(KV.Registry, [KV.Registry]),
      supervisor(KV.Bucket.Supervisor, [])
    ]

    # When a child process crashes, the supervisor will
    # only kill and restart child processes which were
    # started after the crashed child.
    # (e.g. KV.Registry will not be restarted if KV.Bucket.Supervisor crashes)
    supervise(children, strategy: :rest_for_one)
  end
end
