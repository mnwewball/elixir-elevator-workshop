defmodule Elevator.DefaultStateMachine do
  @moduledoc """
  Module which implements the default elevator state machine for the Ruta N building.
  """

  @doc """
  Determines the next state of the elevator given the current `state` of the
  elevator. This `state` includes its current storey, its movement status,
  its queue, and a context which has the lowest and highest storeys of the
  building.
  """
  def transition(state) do
    { _, _, _, context } = state
    { lower_storey, upper_storey } = context

    next = next_stop(state)

    case state do
      # The elevator is at the desired storey, open the doors!
      { current_storey, _, queue, _ } when current_storey == next ->
        { next, :serving, Enum.filter(queue, &(&1 == next)), context }
      # The elevator isn't moving, decide whether to go up or down
      { current_storey, moving?, queue, _ } when moving? == :idle or moving? == :serving ->
        { current_storey, if current_storey > next do :down else :up end, queue, context }
      # The elevator was going up, and now needs to go down
      { current_storey, :up, queue, _ } when current_storey > next or current_storey == upper_storey ->
        { current_storey, :down, queue, context }
      # The elevator can keep going up
      { current_storey, :up, queue, _ } ->
        { current_storey + 1, :up, queue, context }
      # The elevator was going down, and now needs to go up
      { current_storey, :down, queue, _ } when current_storey < next or current_storey == lower_storey ->
        { current_storey, :up, queue, context }
      # The elevator can keep going down
      { current_storey, :down, queue, _ } ->
        { current_storey - 1, :down, queue, context }
    end
  end

  defp next_stop({ current_storey, _, queue, _ }) do
    # Gets the enqueued storey which is nearer
    next = Enum.min_by(queue, &(abs(&1 - current_storey)))
  end
end
