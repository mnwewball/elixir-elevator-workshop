defmodule Elevator.Constraints do

    defstruct lowest_floor: 0, highest_floor: 0

    alias Elevator.Constraints

    @agent_name __MODULE__


    @spec set(constraints :: %Constraints{}) :: :ok 
    def set(constraints) do

        if Process.whereis(@agent_name) do
            Agent.update(@agent_name, fn _ -> constraints end)
        else
            Agent.start_link(fn -> constraints end, [name: @agent_name])
            :ok
        end

    end


    @spec get :: %Constraints{} | {:error, String.t}
    def get() do

        if Process.whereis(@agent_name) do
            Agent.get(@agent_name, fn constraints -> constraints end)
        else
            %Constraints{}
        end

    end
end