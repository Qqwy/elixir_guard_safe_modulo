require Modulo
require Integer

dividends = StreamData.integer()
divisors  = StreamData.integer() |> StreamData.filter(&(&1 != 0))
args =
  Stream.zip(dividends, divisors)

Benchee.run(
  %{
    "mod (non-guard)" => fn input ->
      Enum.map(input, fn {a, b}  -> Modulo.mod(a, b) end)
    end,
    "mod (unoptimized guard)" => fn input ->
      Enum.map(input, fn {a, b}  -> Modulo.unoptimized_guard_safe_mod(a, b) end)
    end,
    "mod (optimized guard)" => fn input ->
      Enum.map(input, fn {a, b}  -> Modulo.guard_safe_mod(a, b) end)
    end,
    "rem" => fn input ->
      Enum.map(input, fn {a, b} -> rem(a, b) end)
    end
  },
  time: 5,
  formatters: [
    Benchee.Formatters.HTML,
    {Benchee.Formatters.Console, extended_statistics: true}
  ],
  inputs: %{
    "1" => Enum.take(args, 1),
    "100" => Enum.take(args, 100),
    "1000" => Enum.take(args, 1_000),
    "10000" => Enum.take(args, 10_000),
  }
)
