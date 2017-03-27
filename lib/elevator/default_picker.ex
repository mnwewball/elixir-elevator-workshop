defmodule Elevator.DefaultElevatorPicker do
  def pick_candidate(elevator_states, from_storey, to_storey) do
    # Is the user going up? Get the elevators going up, servicing lower storeys
    if from_storey < to_storey do
      # Pick the one with the smallest queue
      Elevator.Function.try_until([
        { fn states -> Enum.filter(states, &(coming_up?(&1, from_storey))) end, { &(length(&1) === 0), &(pick_smallest_queue(&1)) } },
        { &(pick_smallest_queue(&1)) }
      ], elevator_states)
      end
    # Is the user going down? Get the elevators going down, servicing upper storeys
    else
      # Pick the one with the smallest queue
      Elevator.Function.try_until([
        { fn states -> Enum.filter(states, &(coming_down?(&1, from_storey))) end, { &(length(&1) === 0), &(pick_smallest_queue(&1)) } },
        { &(pick_smallest_queue(&1)) }
      ], elevator_states)
    end
  end

  defp coming_up?(state, from_storey) do
    { _, {current_storey, direction, _, _ } = state
    direction === :up and current_storey < from_storey
  end

  defp coming_down?(state, from_storey) do
    { _, {current_storey, direction, _, _ } = state
    direction === :down and current_storey > from_storey
  end

  defp pick_smallest_queue(elevator_states) do
    Enum.min_by(elevator_states, )
  end
end
