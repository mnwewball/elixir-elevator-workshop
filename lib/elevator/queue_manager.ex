defmodule Elevator.QueueManager do

    alias Elevator.Constraints
    alias Elevator.State
    alias Elevator.Request
    

    @spec add_request(state :: %State{}, request :: Request.new) :: {:ok, list(Request.t)}
    @doc "Adds a request to the queue"
    def add_request(state, request) do

        {from, to} = request
        %{lowest_floor: lf, highest_floor: hf} = Constraints.get()
        queue = state.queue
        
        new_queue = if from <= hf and from >= lf and to <= hf and to >= lf and from != to do
            queue ++ [request]
        else
            queue
        end

        {:ok, new_queue}

    end


    @spec cancel_request(state :: %State{}, request :: Request.new) :: {:ok, list(Request.t)}
    @doc "Cancels a request in the queue"
    def cancel_request(state, request) do

        queue = state.queue
        new_queue = Enum.filter(queue, fn item -> item != request end)
        {:ok, new_queue}

    end

end 