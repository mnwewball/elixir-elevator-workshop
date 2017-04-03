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
  @tick_interval 1000

  @doc """
  Given the elevator's `initial_state`, assign it a `state_machine` for resolving
  state transitions and start receiving events.
  """
  def start_elevator(initial_state) do
    timer = start_timer()
    update_elevator({initial_state | context: %{ initial_state.context | timer: timer }})
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
      [ { :request, from, to }  | remaining ] when from == floor ->
        new_queue = enqueue({:destination, to}, remaining)
        %Elevator{ state | direction: :idle, moving?: false, queue: new_queue }
      [ { :request, from, _ } | _ ] ->
        direction = if floor < from do :up else :down end
        %Elevator{ state | direction: direction }
      [ { :destination, to } | remaining ] when to == floor ->
        %Elevator{ state | direction: :idle, moving?: false, queue: remaining }
      [ { :destination, to } | _ ] ->
        direction = if floor < to do :up else :down end
        %Elevator{ state | direction: direction }
      [] ->
        %Elevator{ current: floor, direction: :idle }
    end
  end

  # Function to start the timer
  defp start_timer() do
    { _, timer } = :timer.send_interval @tick_interval, self(), { :tick }
    timer
  end

  defp enqueue(floor_request = {:request, from, to}, state = { context: %{ lowest_floor: lf, highest_floor: hf }}) do

    # Adds a floor to the queue if it's not already there
    if from < lf or from > hf or to < lf or to > hf or from == to or Enum.member?(state.queue, floor_request) do
      state
    else
      %Elevator{ state | queue: queue ++ [ floor_request ] }
    end
  end

  defp answer_back_state(state, pid) do
    # Answers back a message
    send pid, state
  end
end
