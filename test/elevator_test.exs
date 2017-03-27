defmodule ElevatorTest do
  use ExUnit.Case
  doctest Elevator.Elevator

  test "starts an elevator" do
    context = %ElevatorContext{lowest_floor: -2, highest_floor: 8}
    initial_state = %Elevator{ current: 0, direction: :idle, status: :ok, moving?: false, queue: [], context: context }
    pid = spawn fn () -> start_elevator(initial_state) end
    
    send pid, { :dismount }
  end
end
