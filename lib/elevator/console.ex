defmodule Elevator.Console do
  @moduledoc """
  Module with which people request the elevator.
  """

  def load_console(pids, storey) {
    IO.puts "Loading console for storey #{storey}"
    result = spawn_link fn -> take_commands(pids, floor) end
  }

  def take_commands(pids, from_storey) do
    receive do
      { :to_storey, to_storey } ->
        IO.puts "Command received in storey #{from_storey} for storey #{to_storey}"
        if from_storey != to_storey do
          process_command(pids, from_storey, to_storey)
        end
    end
    take_commands(pids, from_storey)
  end

  defp process_command(pids, from_storey, to_storey, picker \\ &Elevator.DefaultElevatorPicker.pick_candidate/3) do
    # Broadcast :get_info message to all elevators first
    for pid <- pids, do: send pid, { :get_info, self() }
    # Expect and take responses from every elevator
    elevator_states = for _ <- pids, do: (
      receive do
        { :returned_info, state } -> { pid, state }
      end
    )
    # Based on the state of each elevator, pick one (not necessarily the best ;)
    # And request it.
    IO.puts "Picking an elevator to service request"
    elevator_pid = picker.(elevator_states, from_storey, to_storey)
    IO.puts "Requesting #{elevator_pid} to go from storey #{from_storey} to #{to_storey}"
    send elevator_pid, { :request, from_storey, to_storey }
  end
end
