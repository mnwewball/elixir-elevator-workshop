defmodule Elevator.Function do
  @doc """
  This is a high-order function which allows to compose a nested flow of conditionals.
  """
  def try_until(flow, elevator_states) do
    [h | t] = flow
    case h do
      { path, { condition, alternate_path }} ->
        result = path.(elevator_states)
        if condition.(result) do
          alternate_path.(result)
        else
          compose(t, elevator_states)
        end
      { path } -> path.(elevator_states)
    end
  end
end
