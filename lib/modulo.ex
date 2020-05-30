defmodule Modulo do

    # guard-safe `max` operation, `a` and `b` need to be integers.
  defp guard_safe_int_max(a, b) do
    quote do 
      div((unquote(a) + unquote(b)) + abs(unquote(a) - unquote(b)), 2)
    end
  end

  # guard-safe `sign` operation, as long as both `a` and `b` are integers.
  # To prevent division-by-zero of the naïve `div(x, abs(x))` solution, observe that:
  #  x == 0  -> max(abs(0), 1) == 1, and div(0, 1) == 0, which is the desired result
  #  x != 0  -> max(abs(x), 1) == abs(x), 
  # so `max(abs(x), 1)` is substituted for `abs(x)`.
  defp int_sign(x) do
    quote do
      div(unquote(x), unquote(guard_safe_int_max(quote do abs(unquote(x)) end, 1)))
    end
  end

  # Integer Floor Division, 
  # Erlang's BIF `div/2` rounds towards zero.
  # `floor_div/2` always rounds down.
  # see https://en.wikipedia.org/wiki/Modulo_operation
  defp unoptimized_floor_div(a, n) do
    res = quote do
      div(unquote(a), unquote(n)) + div(unquote(int_sign(quote do rem(unquote(a), unquote(n)) * unquote(n) end)) - 1, 2)
    end
    res
  end

  # Only exposed directly for the benchmark
  @doc false
  defmacro unoptimized_guard_safe_mod(dividend, divisor) do
    quote do
      unquote(dividend) - (unquote(divisor) * unquote(unoptimized_floor_div(dividend, divisor)))
    end
  end

  # Integer Floor Division, 
  # Erlang's BIF `div/2` rounds towards zero.
  # `floor_div/2` always rounds down.
  # see https://en.wikipedia.org/wiki/Modulo_operation
  defp floor_div(a, n) do
    res = quote do
      div(unquote(a), unquote(n)) + (rem(unquote(a), unquote(n)) * unquote(n) >>> abs(unquote(a) * unquote(n)))
    end
    res
  end

  # Only exposed directly for the benchmark
  @doc false
  defmacro guard_safe_mod(dividend, divisor) do
    quote do
      unquote(dividend) - (unquote(divisor) * unquote(floor_div(dividend, divisor)))
    end
  end

  @doc """
  Computes the modulo remainder of an integer division.

  `Modulo.mod/2` uses floored division, which means that 
  the result will always have the sign of the `divisor`.

  Raises an `ArithmeticError` exception if one of the arguments is not an
  integer, or when the `divisor` is `0`.

  When the only expected input are positive numbers, use `rem/2` over `Modulo.mod/2` because
  its implementation is more efficient.

  Allowed in guard tests.

  ## Examples

      iex> Modulo.mod(5, 2)
      1
      iex> Modulo.mod(6, -4)
      -2

  """
  @spec mod(integer, integer) :: integer
  defmacro mod(dividend, divisor) do
    in_module? = (__CALLER__.context == nil)
    if not in_module? do
      # Guard-clause implementation
      guard_safe_mod(dividend, divisor)
    else
      # Normal implementation
      quote do
        bound_divisor = unquote(divisor)
        remainder = rem(unquote(dividend), bound_divisor)
        if remainder * bound_divisor < 0 do
          remainder + bound_divisor
        else
          remainder
        end
      end
    end
  end

end
