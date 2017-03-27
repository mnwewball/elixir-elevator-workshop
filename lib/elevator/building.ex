defmodule Elevator.Building do
  def start(elevators, context) do
    # Save the pids for use by the consoles
    elevator_pids = initialize_elevators(context, elevators)
  end

  defp initialize_elevators(elevators, context) do
    # Bootstrap as many elevators as specified
    for _ <- 1..elevators, do: bootstrap_elevator(context)
  end

  defp bootstrap_elevator(context = { lowest_storey, highest_storey }) do
    # :rand.uniform(n) returns a number in the range 1 <= x <= n and for that reason we need to
    # compensate by normalizing the range.
    initial_storey = :rand.uniform(highest_storey - (lowest_storey + 1)) + (lowest_storey + 1)
    spawn fn -> { initial_storey, :idle, [], context } |> Elevator.Elevator.start_elevator end
  end
end
