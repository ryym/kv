defmodule KV.Bucket do
  def start_link() do
    Agent.start_link(fn -> %{} end)
  end

  def get(bucket, key) do
    Agent.get(bucket, fn m -> m[key] end)
  end

  def put(bucket, key, value) do
    Agent.update(bucket, fn m -> Map.put(m, key, value) end)
  end
end
