defmodule ElevatorContext do
  defstruct lowest_floor: 0, highest_floor: 0
end

defmodule Elevator do
  defstruct current: 0, direction: :idle, status: :ok, moving?: false, queue: [], context: %ElevatorContext{}
end

defmodule Elevator.Elevator do
  @moduledoc """
  Module for managing state and event management of an individual elevator.
  """

  @doc """
  Given the elevator's `initial_state`, assign it a `state_machine` for resolving
  state transitions and start receiving events.
  """
  def start_elevator(initial_state) do
    update_elevator(initial_state)
  end

  defp update_elevator(state) do
    IO.puts "In update_elevator"
    receive do
      # A clock tick event
      { :tick } ->
        state |> state_machine_naive |> update_elevator
      # A get info event
      { :get_info, pid } ->
        { :returned_info, state } |> answer_back_state(pid)
        state |> update_elevator
      # The elevator has been requested
      { :request, floor } ->
        floor |> enqueue(state) |> update_elevator
      # dismount gracefully tears down the elevator
      { :dismount } -> { :ok }
    end
  end

  @doc """
  """
  defp state_machine_naive(:make_stop, state = { floor, direction, _, _, queue }) do

    # Check if there are any floors left to visit in the queue. If so, move the
    # elevator in the direction of the next floor in the queue. Otherwise, leave 
    # the elevator idle.
    case queue do
      [ next | remaining ] when head == floor ->
        %Elevator{ current: floor, direction: :idle, moving?: false, queue: remaining }
      [ next | remaining ] ->
        direction = if floor - head < 0 do :up else :down end
        %Elevator{ current: floor, direction: direction, queue: remaining }
      [] ->
        %Elevator{ current: floor, direction: :idle }
    end
  end

  defp enqueue(floor, state) do
    # Adds a floor to the queue if it's not already there
    if Enum.member?(state.queue, floor) do
      state
    else
      %Elevator{ state | queue: queue ++ [ floor ] }
    end
  end

  defp answer_back_state(state, pid) do
    # Answers back a message
    send pid, state
  end
end
