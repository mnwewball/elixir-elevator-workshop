defmodule Elevator.Validator do

    alias Elevator.Constraints


    def validate_request(request) do

        %{lowest_floor: lf, highest_floor: hf} = Constraints.get

        case request do
            {from, to} ->
                from >= lf and from <= hf and to >=lf and to <= hf and from != to
            _ ->
                false
        end

    end


    def validate_floor(floor) do
    
        %{lowest_floor: lf, highest_floor: hf} = Constraints.get

        floor >= lf and floor <= hf

    end

end