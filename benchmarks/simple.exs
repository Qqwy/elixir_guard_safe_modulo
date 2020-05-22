require Modulo

dividends = StreamData.integer()
divisors  = StreamData.integer() |> StreamData.filter(&(&1 != 0))
args =
  Stream.zip(dividends, divisors)
  |> Stream.take(1_000)
  |> Enum.to_list

Benchee.run(
  %{
    "Modulo.mod (body)" => fn ->
      Enum.map(args, fn {a, b}  -> Modulo.mod(a, b) end)
    end,
    "Modulo.mod (guard)" => fn ->
      Enum.map(args, fn {a, b}  -> Modulo.guard_safe_mod(a, b) end)
    end,
    "rem" => fn ->
      Enum.map(args, fn {a, b} -> rem(a, b) end)
    end
  },
  time: 10,
  formatters: [{Benchee.Formatters.Console, extended_statistics: true}],
)
