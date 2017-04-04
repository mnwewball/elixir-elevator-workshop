defmodule ElevatorContext do
  defstruct lowest_floor: 0, highest_floor: 0, timer: nil
end

defmodule Elevator do
  defstruct current: 0, action: :idle, status: :ok, queue: [], context: %ElevatorContext{}
end

# Define the module which will host the elevator's functionality
defmodule Elevator.Elevator do

  # The tick interval for updating the elevator state
  @tick_interval 1000

  # Define the elevator's bootstrap function
  def start_elevator(initial_state) do
    
    sm_pid = spawn fn () -> Elevator.StateManager.init(initial_state) end
    process_events(sm_pid)
  end

  defp process_events(sm_pid) do
    receive do
      event -> handle_event(event, sm_pid)
    end
  end

  # Function to handle events
  defp handle_event({ :tick }, sm_pid) do
    state = fetch_state(sm_pid)

    case state do
      %{ current: current, queue: queue, action: action } ->
        case queue do
          [ { from, _ } | tail ] when from > current ->
            update_state sm_pid, %{ state | action: :up }
          [ { from, _ } | tail ] when from < current ->
            update_state sm_pid, %{ state | action: :down }
          [ { from, to } | tail ] when from == current ->
            new_queue = [ { to } ] ++ tail
            update_state sm_pid, %{ state | action: :open_doors, queue: new_queue }
          [ { to } | tail ] when from > current ->
            update_state sm_pid, %{ state | action: :up }
          [ { to } | tail ] when from < current ->
            update_state sm_pid, %{ state | action: :down }
          [ { to } | tail ] when from == current ->
            update_state sm_pid, %{ state | action: :open_doors, queue: tail }
          [] -> update_state sm_pid, %{ state | action: :idle }
        end
        
    end
  end
  defp handle_event({ :request, from, to }, sm_pid) do
    state = fetch_state(sm_pid)
    %{ queue: queue } = state
    new_queue = queue ++ [ { from, to } ]
    update_state %{ state | queue: new_queue }
  end

  defp fetch_state(sm_pid) do
    send sm_pid, { :fetch, self() }
    receive do
      { :fetched, state } ->
        state
    end
  end

  defp update_state(sm_pid, new_state) do
    send sm_pid, { :update, new_state }
  end

    # Receive messages
    
      # A clock tick event
      
        # Update machine state through a state machine

      # A get info event
      
      # The elevator has been requested
      
        # Update queue

      # dismount gracefully tears down the elevator
      
  # Define a state machine function

    # Check if there are any floors left to visit in the queue. If so, move the
    # elevator in the direction of the next floor in the queue. Otherwise, leave 
    # the elevator idle.

      # If the next in the queue is the current floor, open the doors. And remove 
      # the current floor from the queue.

      # If there's more floors in the queue, move towards it. If the doors were 
      # closed (i.e. the elevator was moving) change the current floor, otherwise
      # pretend the doors just closed and the elevator started moving.

      # If there's no more floors in the queue, go idle.
    
  # Function to start the timer
  defp start_timer() do
    { _, timer } = :timer.send_interval @tick_interval, self(), { :tick }
    timer
  end

  # Function to enqueue a floor request
  defp enqueue(floor, state) do
    # Adds a floor to the queue if it's not already there
    if floor < state.context.lowest_floor or floor > state.context.highest_floor or Enum.member?(state.queue, floor) do
      state
    else
      %Elevator{ state | queue: state.queue ++ [ floor ] }
    end
  end

  # Answers back a message
  defp answer_back_state(state, pid) do
    send pid, state
  end
end
