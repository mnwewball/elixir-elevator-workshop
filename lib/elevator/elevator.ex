defmodule ElevatorContext do
  defstruct lowest_floor: 0, highest_floor: 0, timer: nil
end

defmodule Elevator do
  defstruct current: 0, action: :idle, status: :ok, queue: [], context: %ElevatorContext{}
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
    IO.puts "Starting elevator..."
    IO.puts "Starting timer..."
    timer = start_timer()

    IO.puts "Timer created #{Kernel.inspect timer}"
    update_elevator(%{ initial_state | context: %{ initial_state.context | timer: timer } })
  end

  defp update_elevator(state) do
    
    receive do
      # A clock tick event
      { :tick } ->
        IO.puts "Clock ticked..."
        IO.puts "Current state: #{Kernel.inspect state}"
        state |> state_machine_naive |> update_elevator
        IO.puts "New state:     #{Kernel.inspect state}"
      # A get info event
      { :get_info, pid } ->
        { :returned_info, state } |> answer_back_state(pid)
        state |> update_elevator
      # The elevator has been requested
      request = { :request, from, to } ->
        IO.puts "Floor requested #{from}->#{to}"
        request |> enqueue(state) |> update_elevator
      # dismount gracefully tears down the elevator
      { :dismount } -> 
        IO.puts "Dismounting..."
        { :ok }
    end
  end

  defp state_machine_naive(state = %{ current: floor, action: action, queue: queue }) do

    # Check if there are any floors left to visit in the queue. If so, move the
    # elevator in the direction of the next floor in the queue. Otherwise, leave 
    # the elevator idle.
    case queue do
      [ { :request, from, to }  | remaining ] when from == floor ->
        new_queue = enqueue({:destination, to}, remaining)
        %Elevator{ state | action: :open_doors, queue: new_queue }
      [ { :request, from, _ } | _ ] ->
        action = if floor < from do :go_up else :go_down end
        %Elevator{ state | action: action }
      [ { :destination, to } | remaining ] when to == floor ->
        %Elevator{ state | action: :idle, queue: remaining }
      [ { :destination, to } | _ ] ->
        action = if floor < to do :go_up else :go_down end
        %Elevator{ state | action: action }
      [] ->
        %Elevator{ current: floor, action: :idle }
    end
  end

  # Function to start the timer
  defp start_timer() do
    { _, timer } = :timer.send_interval @tick_interval, self(), { :tick }
    timer
  end

  defp enqueue(floor_request = {:request, from, to}, state = %{ context: %{ lowest_floor: lf, highest_floor: hf }}) do

    # Adds a floor to the queue if it's not already there
    if from < lf or from > hf or to < lf or to > hf or from == to or Enum.member?(state.queue, floor_request) do
      state
    else
      %Elevator{ state | queue: state.queue ++ [ floor_request ] }
    end
  end

  defp answer_back_state(state, pid) do
    # Answers back a message
    send pid, state
  end
end
