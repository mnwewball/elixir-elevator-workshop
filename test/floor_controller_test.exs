defmodule Elevator.FloorControllerTest do

  use ExUnit.Case
  doctest Elevator.FloorController

  alias Elevator.Elevator, as: Elevators
  alias Elevator.Constraints
  alias Elevator.FloorController


  setup _context do

    Constraints.set(%Constraints{lowest_floor: -2, highest_floor: 8})

    elevator_name_1 = :first_elevator
    config_1 = %{ name: elevator_name_1 }

    elevator_name_2 = :second_elevator
    config_2 = %{ name: elevator_name_2 }

    elevator_name_3 = :third_elevator
    config_3 = %{ name: elevator_name_3 }

    # Create three elevators
    Elevators.create(config_1)
    Elevators.create(config_2)
    Elevators.create(config_3)

    {:ok, [ elevators: [elevator_name_1, elevator_name_2, elevator_name_3] ]}

  end


  test "connects only correct floor numbers properly", _context do

    assert :ok == FloorController.connect(0)
    assert :ok == FloorController.connect(5)
    refute :ok == FloorController.connect(-3)
    assert :ok == FloorController.connect(-1)
    refute :ok == FloorController.connect(10)

  end


  test "connects all floors properly", _context do

    assert :ok == FloorController.connect_all()

  end


  test "disconnects only correct floor numbers", _context do

    FloorController.connect(0)
    FloorController.connect(1)
    FloorController.connect(5)

    assert :ok == FloorController.disconnect(-1)
    assert :ok == FloorController.disconnect(0)
    assert :ok == FloorController.disconnect(1)
    assert :ok == FloorController.disconnect(5)
    refute :ok == FloorController.disconnect(10)

  end


  test "disconnects all floor numbers", _context do

    FloorController.connect_all()

    assert :ok == FloorController.disconnect_all()

  end


  test "assigns requests only if the floors are valid and if the controller is connected", context do

    FloorController.connect(0)

    assert :ok == FloorController.request({0, 5})
    assert :ok == FloorController.request({0, -1})
    refute :ok == FloorController.request({1, 2})
    refute :ok == FloorController.request({0, -3})
    refute :ok == FloorController.request({0, 10})
    
    assert max_queue_count(context[:elevators]) > 0
    assert sum_queue_count(context[:elevators]) == 2

  end


  test "cancels requests only if the controller is connected", context do

    FloorController.connect(0)

    FloorController.request({0, 5})
    FloorController.request({0, -1})

    assert :ok == FloorController.cancel({0, 5})
    assert :ok == FloorController.cancel({0, -1})
    refute :ok == FloorController.cancel({1, 2})
    assert :ok == FloorController.cancel({0, -3})
    assert :ok == FloorController.cancel({0, 10})
    
    refute max_queue_count(context[:elevators]) > 0
    assert sum_queue_count(context[:elevators]) == 0

  end


  defp max_queue_count(elevators) do
  
    elevators
      |> Enum.map(fn elevator -> Elevators.current_state(elevator) end)
      |> Enum.map(fn state -> Enum.count(state.queue) end)
      |> Enum.max()

  end


  defp sum_queue_count(elevators) do

    elevators
      |> Enum.map(fn elevator -> Elevators.current_state(elevator) end)
      |> Enum.map(fn state -> Enum.count(state.queue) end)
      |> Enum.sum()

  end

end
