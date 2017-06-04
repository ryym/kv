# To keep a registry running even if some buckets crash,
# we should not link Bucket process to Registry process.
# But using `Agent.start` is a bad idea because all buckets
# would not be linked to any process in that case. This means
# bucket processes would remain alive after the `:kv` application stopped.
#
# We can solve this issue by defining a supervisor that will spawn and
# supervise all buckets.

defmodule KV.Bucket.Supervisor do
  use Supervisor

  @name KV.Bucket.Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def start_bucket do
    Supervisor.start_child(@name, [])
  end

  def init(:ok) do
    children = [
      # Do not restart if a process crashed.
      worker(KV.Bucket, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
