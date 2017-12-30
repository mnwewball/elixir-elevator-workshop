defmodule Elevator.StateDynamics do

    alias Elevator.QueueManager
    alias Elevator.Constraints


    @doc "Transitions from the current state to the next"
    def transition(state) do

        %{ highest_floor: hf, lowest_floor: lf } = Constraints.get()

        case state do
            %{ current: current, queue: queue, action: action } ->
                new_state = case queue do

                    # If next floor in queue is upwards, move upwards
                    [ { from, _ } | _ ] when from > current ->
                        if action == :up and current + 1 <= hf do
                            %{ state | current: current + 1 }
                        else
                            %{ state | action: :up }
                        end

                    # If next floor in queue is downwards, move downwards
                    [ { from, _ } | _ ] when from < current ->
                        if action == :down and current - 1 >= lf do
                            %{ state | current: current - 1 }
                        else
                            %{ state | action: :down }
                        end

                    # If next floor is the current one, open doors and update queue
                    [ { from, to } | tail ] when from == current ->
                        new_queue = [ { to } ] ++ tail
                        %{ state | action: :open_doors, queue: new_queue }

                    # If next floor in queue is upwards, move upwards
                    [ { to } | _ ] when to > current ->
                        if action == :up and current + 1 <= hf do
                            %{ state | current: current + 1 }
                        else
                            %{ state | action: :up }
                        end

                    # If next floor in queue is downwards, move downwards
                    [ { to } | _ ] when to < current ->
                        if action == :down and current - 1 >= lf do
                            %{ state | current: current - 1 }
                        else
                            %{ state | action: :down }
                        end

                    # If next floor is the current one, open doors and update queue
                    [ { to } | tail ] when to == current ->
                        %{ state | action: :open_doors, queue: tail }
                    
                    # If some other message is found, ignore it
                    [ _ | tail ] ->
                        %{ state | queue: tail }

                    # If queue is empty, sit idle
                    [ ] ->
                        %{ state | action: :idle }
                end

                {:ok, new_state}

            _ ->
                {:error, 'Invalid state'}
        end

    end


    @doc "Adds a request to the queue"
    def add_request(state, request) do

        {:ok, new_queue} = QueueManager.add_request(state, request)

        {:ok, %{ state | queue: new_queue }}

    end


    @doc "Cancels a request in the queue, if present"
    def cancel_request(state, request) do

        {:ok, new_queue} = QueueManager.cancel_request(state, request)

        {:ok, %{ state | queue: new_queue }}

    end
end