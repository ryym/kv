# https://elixir-lang.org/getting-started/mix-otp/genserver.html

defmodule KV.Registry do
  use GenServer

  ### Client API

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  @doc"""
  Looks up the bucket pid for `name` stored in `server`.
  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc"""
  Ensures there is a bucket associated to the given `name` in `server`.
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  ### Server Callbacks

  # The first argument is a second argument of `GenServer.start_link`
  def init(:ok) do
    names = %{}
    refs = %{}
    {:ok, {names, refs}}
  end

  # Calls are synchronous while Casts are asynchronous.
  def handle_call({:lookup, name}, _from, {names, _} = state) do
    # {:reply, reply_to_client, new_state}
    {:reply, Map.fetch(names, name), state}
  end

  def handle_cast({:create, name}, {names, refs}) do
    if Map.has_key?(names, name) do
      {:noreply, names}
    else
      {:ok, pid} = KV.Bucket.start_link
      ref = Process.monitor(pid)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, pid)
      {:noreply, {names, refs}}
    end
  end

  # `handle_info` receives generic messages sent to the Registry process.
  # We can handle messages from processes created in `handle_cast` by
  # monitoring them. When a process monitors another process, it receives
  # messages sent from the monitored one (uni-directional link).
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  def handle_info(msg, state) do
    IO.inspect(msg)
    {:noreply, state}
  end
end
