defmodule Elevator.CLI do
  def run(argv) do
    argv |> parse_args |> process_command
  end

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean], aliases: [h: :help])

    case parse do
      { [ help: true ], _, _ } ->
        :help
      { _, [ elevators, lowest_storey, highest_storey ], _ } ->
        if storeys_valid?(lowest_storey) and storeys_valid?(lowest_storey, highest_storey) and elevators_valid?(elevators) do
          { elevators, lowest_storey, highest_storey }
        else
          :help
        end
      _ ->
        :help
    end
  end

  defp storeys_valid?(lowest_storey, highest_storey) do
    { hs_valid?, hs } = Elevator.ParamValidation.validate_int_param(highest_storey)
    { ls_valid?, ls } = Elevator.ParamValidation.validate_int_param(lowest_storey)

    # If both given storeys are valid and the highest is indeed the highest, then fine.
    hs_valid? and ls_valid? and hs > ls
  end

  defp elevators_valid?(elevators) do
    Elevator.ParamValidation.int_param_valid?(elevators, &(&1 > 0))
  end

  def process_command(:help) do
    IO.puts """
    usage: elevators [-h] <elevators> <lowest_storey> <highest_storey>

    Where:
        elevators       The number of elevators in the building
        lowest_storey   The lowest storey in the building
        highest_storey  The highest storey in the building
    """
    System.halt(0)
  end

  def process_command({ elevators, lowest_storey, highest_storey }) do
    IO.puts """
    You chose:
      Lowest storey:  #{lowest_storey}
      Highest storey: #{highest_storey}
      Elevators:      #{elevators}
    :)
    """
    IO.puts "It's already morning..."
    IO.puts "People just start to arrive..."

    Elevator.Building.start(elevators, { lowest_storey, highest_storey })
  end
end
