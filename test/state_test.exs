defmodule Elevator.StateTest do

    use ExUnit.Case
    doctest Elevator.State

    alias Elevator.State


    test "creates a state manager for an elevator and correctly updates and fetches its state" do
        
        elevator_name = :test

        {:ok, original_state} = State.create(elevator_name)
        assert original_state.current == 0
        
        updated_state = %{original_state | current: 10}
        State.update(elevator_name, updated_state)
        
        saved_state = State.fetch(elevator_name)

        assert saved_state.current == updated_state.current
        assert saved_state.current != original_state.current
    
    end
    
end