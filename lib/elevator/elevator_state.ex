defmodule Elevator.StateManager do
  def init(initial_state) do
    initial_state |> receive_requests |> init
  end

  def receive_requests(state) do
    receive do
      { :fetch, pid } -> 
        fetch_state(pid, state)
        state
      { :update, new_state } -> 
        update_state(new_state)
      _ -> 
        IO.puts "Not supported"
        receive_requests(state)
    end
  end

  def update_state(new_state) do
    new_state
  end

  def fetch_state(pid, state) do
    send pid, { :fetched, state }
  end
end