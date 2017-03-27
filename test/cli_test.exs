defmodule CliTest do
  use ExUnit.Case
  import Elevator.CLI, only: [ parse_args: 1 ]

  test ":help returned by option parsing with -h and --help options" do
    assert parse_args([ "-h", "something"]) == :help
    assert parse_args([ "-h"]) == :help
  end

  test "three values returned (elevators, lowest_storey, highest_storey) if three given" do
    assert parse_args([ 4, -2, 7 ]) == { 4, -2, 7 }
    assert parse_args([ 4, -2, "something" ]) == :help
    assert parse_args([ "something", -2, 7 ]) == :help
    assert parse_args([ "something", "other", 7 ]) == :help
    assert parse_args([ -1, -2, 7 ]) == :help
    assert parse_args([ 4, 7, -2 ]) == :help
  end

  test ":help returned when passed less/more arguments than expected" do
    assert parse_args([ "something" ]) == :help
    assert parse_args([ 4, -2, 7, "something" ]) == :help
    assert parse_args([ 4, -2, 7, "something", "something_else" ]) == :help
  end
end
