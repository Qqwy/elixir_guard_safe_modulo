require Modulo

dividends = StreamData.integer()
divisors  = StreamData.integer() |> StreamData.filter(&(&1 != 0))
args =
  Stream.zip(dividends, divisors)

Benchee.run(
  %{
    "Modulo.mod (body)" => fn input ->
      Enum.map(input, fn {a, b}  -> Modulo.mod(a, b) end)
    end,
    "Modulo.mod (guard)" => fn input ->
      Enum.map(input, fn {a, b}  -> Modulo.guard_safe_mod(a, b) end)
    end,
    "rem" => fn input ->
      Enum.map(input, fn {a, b} -> rem(a, b) end)
    end
  },
  time: 5,
  formatters: [{Benchee.Formatters.Console, extended_statistics: true}],
  inputs: %{
    "1" => Enum.take(args, 1),
    "100" => Enum.take(args, 100),
    "1_000" => Enum.take(args, 1_000),
    "10_000" => Enum.take(args, 10_000),
  }
)
