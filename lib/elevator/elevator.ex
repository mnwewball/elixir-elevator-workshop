defmodule ElevatorContext do
  defstruct lowest_floor: 0, highest_floor: 0, timer: nil
end

defmodule Elevator do
  defstruct current: 0, action: :idle, status: :ok, queue: [], context: %ElevatorContext{}
end

# Define the module which will host the elevator's functionality

  # The tick interval for updating the elevator state

  # Define the elevator's bootstrap function
  
    # Print some debugging messages
    
    # Start the timer

    # Call the update_elevator function

  # Function to update elevator's state

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
