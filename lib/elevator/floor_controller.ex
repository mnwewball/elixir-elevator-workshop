defmodule Elevator.FloorController do

    use GenServer

    alias Elevator.Scheduler
    alias Elevator.Constraints
    alias Elevator.Validator
    alias Elevator.Request


    @spec connect(floor :: integer) :: :ok | {:error, String.t}
    def connect(floor) do

        if ! Validator.validate_floor(floor) do
            {:error, 'Invalid floor number'}
        else
            floor_name = resolve_name(floor)

            if ! Process.whereis(floor_name) do
                GenServer.start_link(__MODULE__, nil, [name: floor_name])
            end

            :ok
        end

    end


    @spec connect_all :: :ok
    def connect_all() do

        %{lowest_floor: lf, highest_floor: hf} = Constraints.get

        if lf < hf do
            lf..hf
                |> Enum.each(&connect(&1))
        end

        :ok
        
    end


    @spec disconnect(floor :: integer) :: :ok | {:error, String.t}
    def disconnect(floor) do

        if ! Validator.validate_floor(floor) do
            {:error, 'Invalid floor number'}
        else
            floor_name = resolve_name(floor)

            if Process.whereis(floor_name) do
                GenServer.stop(floor_name)
            end

            :ok
        end

    end


    @spec disconnect_all :: :ok
    def disconnect_all() do

        %{lowest_floor: lf, highest_floor: hf} = Constraints.get

        if lf < hf do
            lf..hf
                |> Enum.each(&disconnect(&1))
        end

        :ok

    end


    @spec request(request :: Request.new) :: :ok | {:error, String.t}
    def request(request = {from, _}) do
    
        floor_name = resolve_name(from)

        if Process.whereis(floor_name) do
            GenServer.call(floor_name, {:request, request})
        else
            {:error, "The floor controller for floor #{from} isn't connected"}
        end

    end


    @spec cancel(request :: Request.new) :: :ok | {:error, String.t}
    def cancel(request = {from, _}) do

        floor_name = resolve_name(from)

        if Process.whereis(floor_name) do
            GenServer.call(resolve_name(from), {:cancel, request})
        else
            {:error, "The floor controller for floor #{from} isn't connected"}
        end
    end


    def init(_) do

        {:ok, nil}

    end


    def handle_call({:request, request = {from, to}}, _from, state) do

        if Validator.validate_request(request) do
            Scheduler.assign_request(request)
            {:reply, :ok, state}
        else
            {:reply, {:error, "Invalid request: {from: #{from}, to: #{to}}"}, state}
        end

    end
    def handle_call({:cancel, request = {from, to}}, _from, state) do

        if Validator.validate_request(request) do
            Scheduler.cancel_request(request)
        end

        {:reply, :ok, state}

    end


    defp resolve_name(floor) do

        String.to_atom("floor_#{floor}")

    end

end