defmodule Elevator.Scheduler do

    alias Elevator.Elevator, as: Elevators
    alias Elevator.Request


    @spec assign_request(request :: Request.new) :: :ok | {:error, String.t}
    def assign_request(request) do

        result = pick_best_candidate(request)

        case result do
            elevator when is_atom(elevator) ->
                Elevators.make_request(elevator, request)

            error ->
                error
        end

    end


    @spec cancel_request(request :: Request.new) :: :ok
    def cancel_request(request) do

        Elevators.current_elevators()
            |> Enum.each(&(Elevators.cancel_request(&1, request)))

    end


    defp pick_best_candidate({from, to}) do

        # First determine whether the user is going up or down
        going = if from > to do :down else :up end

        # Filter out all elevators not currenlty active
        active_elevators_states = Elevators.current_elevators()
            |> Enum.map(&(Elevators.current_state(&1)))
            |> Enum.filter(fn state -> state.status == :ok end)
        
        # Create a map for easy access to the elevator states
        states_map = active_elevators_states
            |> Map.new(fn state -> {state.name, state} end)
        
        # Get all elevators going in the direction of the user
        going_same_way = active_elevators_states
            |> Enum.filter(fn state -> state.action === going or state.action === :idle end)
        
        # If no elevators going in the direction of the user, consider the rest of the elevators
        pre_chosen = if Enum.count(going_same_way) > 0 do
            going_same_way
        else
            active_elevators_states
        end
        
        if Enum.count(pre_chosen) > 0 do
            # Pick the elevators with the smallest queues
            queues = active_elevators_states
                |> Enum.map(fn state -> {state.name, state.queue} end)

            min_count = queues 
                |> Enum.min_by(fn {_, queue} -> Enum.count(queue) end)
                |> elem(1)
                |> Enum.count()
            
            chosen_queues = queues
                |> Enum.filter(fn {_, queue} -> Enum.count(queue) === min_count end)
            
            # Pick the one closest to the from floor. min_by breaks ties by choosing the first match
            chosen_elevator = chosen_queues
                |> Enum.map(&(elem(&1, 0)))
                |> Enum.min_by(fn elevator -> states_map[elevator].current - from end)

            chosen_elevator
        else
            {:error, 'No elevators are on duty. No requests can be queued.'}
        end

    end

end