defmodule Elevator.ElevatorTest do

  use ExUnit.Case
  doctest Elevator.Elevator

  alias Elevator.Elevator, as: Elevators
  alias Elevator.Constraints


  test "correctly starts and turns off three independent elevators" do

    elevator_name_1 = :first_elevator_et
    config_1 = %{ name: elevator_name_1 }

    elevator_name_2 = :second_elevator_et
    config_2 = %{ name: elevator_name_2 }

    elevator_name_3 = :third_elevator_et
    config_3 = %{ name: elevator_name_3 }

    # Create three elevators and make sure all of them are
    # independent processes
    {:ok, pid_1} = Elevators.create(config_1)
    assert is_pid(pid_1)

    {:ok, pid_2} = Elevators.create(config_2)
    assert is_pid(pid_2)
    assert pid_1 != pid_2

    {:ok, pid_3} = Elevators.create(config_3)
    assert is_pid(pid_3)
    assert pid_2 != pid_3
    assert pid_1 != pid_3

    # Turn off and make sure the processes are cleaned up
    Elevators.turn_off(elevator_name_1)
    assert !Process.alive?(pid_1)

    Elevators.turn_off(elevator_name_2)
    assert !Process.alive?(pid_2)

    Elevators.turn_off(elevator_name_3)
    assert !Process.alive?(pid_3)

  end


  test "the elevator moves on every clock tick" do

    elevator_name = :elevator
    constraints = %{ lowest_floor: -2, highest_floor: 8 }
    config = %{ name: elevator_name }

    Constraints.set(constraints)
    {:ok, pid} = Elevators.create(config)
    assert is_pid(pid)

    initial_state = Elevators.current_state(elevator_name)

    make_requests(elevator_name, [{1, 5}])

    # 3.5s would give us enough time for the elevator to move
    :timer.sleep(3500)

    state = Elevators.current_state(elevator_name)

    assert state != initial_state
    assert state.current > initial_state.current

    Elevators.turn_off(elevator_name)

  end


  test "valid floors get added to the queue upon request" do

    elevator_name = :elevator
    constraints = %{ lowest_floor: -2, highest_floor: 8 }
    config = %{ name: elevator_name }

    Constraints.set(constraints)
    {:ok, pid} = Elevators.create(config)
    assert is_pid(pid)

    expected_queue = [{0, 5}, {-1, 0}, {5, 2}]
    make_requests(elevator_name, [{0, 5}, {-1, 0}, {-5, 1}, {8, 9}, {9, 0}, {5, 2}])

    state = Elevators.current_state(elevator_name)

    assert state.queue == expected_queue

    Elevators.turn_off(elevator_name)

  end


  defp make_requests(elevator, requests) do

    for request <- requests do
      Elevators.make_request(elevator, request)
    end

  end

end
