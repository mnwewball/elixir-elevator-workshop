# Define the module which will host the elevator's functionality
defmodule Elevator.Elevator do

  use GenServer

  alias Elevator.State
  alias Elevator.StateDynamics

  # The tick interval for updating the elevator state
  @tick_interval 1000


  def create(config) do

    result = GenServer.start_link(__MODULE__, config, name: config.name)

    elevators = State.fetch()
    State.update([ config.name | elevators ])

    result
  
  end


  def turn_off(elevator) do

    GenServer.stop(elevator)

    elevators = State.fetch()
    State.update(Enum.filter(elevators, fn item -> item != elevator end))

  end


  def make_request(elevator, request) do

    GenServer.call(elevator, {:request, request})

  end


  def cancel_request(elevator, request) do
    
    GenServer.call(elevator, {:cancel, request})

  end


  def current_state(elevator) do
    
    State.fetch(elevator)

  end


  def current_elevators() do

    State.fetch()

  end


  # Define the elevator's bootstrap function
  def init(config) do

    # Create an atom to associate with the SM of this elevator
    elevator_name = config.name

    {:ok, initial_state} = State.create(elevator_name)
    State.update(elevator_name, %{initial_state | timer: start_timer()})

    {:ok, elevator_name}

  end


  # Function to handle events
  def handle_call(command, _from, elevator) do
    
    result = handle_command(command, elevator)

    case result do
      {:ok, new_state} ->
        State.update(elevator, new_state)
        {:reply, :ok, elevator}
      
      {:error, _} ->
        {:reply, result, elevator}
    end

  end


  def handle_cast(command, _from, elevator) do

    handle_info(command, elevator)

  end


  def handle_info(command, elevator) do

    result = handle_command(command, elevator)

    case result do
      {:ok, new_state} ->
        State.update(elevator, new_state)
        {:noreply, elevator}
      
      _ ->
        {:noreply, elevator}
    end

  end


  defp handle_command(command, elevator) do

    state = State.fetch(elevator)

    case command do
      :tick ->
        StateDynamics.transition(state)
      
      {:request, request} ->
        StateDynamics.add_request(state, request)
      
      {:cancel, request} ->
        StateDynamics.cancel_request(state, request)
      
      _ ->
        {:error, 'Invalid command'}
    end

  end
    

  # Function to start the timer
  defp start_timer() do

    { _, timer } = :timer.send_interval(@tick_interval, self(), :tick)
    timer

  end

end
