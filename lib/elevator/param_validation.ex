defmodule Elevator.ParamValidation do
  def int_param_valid?(param, validation \\ &(true)) when is_number(param) do
    validation.(param)
  end
  def int_param_valid?(param, validation \\ &(true)) do
    result = to_integer(param)
    result != :error and validation.(result)
  end

  def validate_int_param(param, validation \\ &(true)) when is_number(param) do
    if validation.(param) do
      { :valid, param }
    else
      { :invalid, param }
    end
  end
  def validate_int_param(param, validation \\ &(true)) do
    result = to_integer(param)
    if result != :error and validation.(result) do
      { :valid, result }
    else
      { :invalid, param }
    end
  end

  defp to_integer(param) do
    if is_number(param) do
      param
    else
      parse_result = Integer.parse(param)

      case parse_result do
        { int, _ } -> int
        _ -> :error
      end
    end
  end
end
