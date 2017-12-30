defmodule Elevator.State do

  defstruct name: nil, current: 0, action: :idle, status: :ok, queue: [], timer: nil

  alias Elevator.State


  @doc "Creates a new state manager. The new state manager will be associated with the given name"
  def create(name) do

    initial_state = %State{name: name}
    Agent.start_link(fn -> initial_state end, [name: resolve_name(name)])
    
    {:ok, initial_state}

  end


  @doc "Updates the state of a given elevator"
  def update(name, new_state) do

    Agent.update(resolve_name(name), fn _ -> new_state end)

  end


  @doc "Updates the list of the currently running elevators"
  def update(elevators) do

    if ! Process.whereis(State) do
      Agent.start_link(fn -> elevators end, [name: State])
    else
      Agent.update(State, fn _ -> elevators end)
    end

  end


  @doc "Gets the state of a given elevator"
  def fetch(name) do

    Agent.get(resolve_name(name), &(&1))

  end


  @doc "Fetches the list of the currently running elevators"
  def fetch() do
  
    if ! Process.whereis(State) do
      []
    else
      Agent.get(State, &(&1))
    end

  end


  defp resolve_name(name) do

    String.to_atom("#{Atom.to_string(name)}_sm")

  end

end