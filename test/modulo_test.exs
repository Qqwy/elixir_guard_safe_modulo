defmodule ModuloTest do
  use ExUnit.Case
  use ExUnitProperties
  doctest Modulo

  property "works for all numbers, has sign of divisor" do
    check all dividend <- StreamData.integer(),
              divisor <- StreamData.integer(),
              divisor != 0,
              dividend != divisor
      do
      res = Modulo.mod(dividend, divisor)
      if res != 0 do
        assert sign(res) == sign(divisor)
      end
    end
  end

  defp sign(0), do: 0
  defp sign(x) when x > 0, do: 1
  defp sign(x) when x < 0, do: -1

  property "same output for positive numbers as `Kernel.rem/2`" do
    check all a <- StreamData.positive_integer(),
      b <- StreamData.positive_integer() do
      assert Modulo.mod(a, b) === rem(a, b)
    end
  end

  property "Raises for 0 divisor" do
    check all dividend <- StreamData.integer() do
      assert_raise ArithmeticError, fn ->
        Modulo.mod(dividend, 0)
      end
    end
  end
end
