defmodule SafeExStruct.TypeChecker do
  # COND ORDER IS IMPORTANT!!!
  def typeof(self) do
    cond do
      is_nil(self) -> nil
      is_atom(self) -> :atom
      is_binary(self) -> :binary
      is_bitstring(self) -> :bitstring
      is_boolean(self) -> :boolean
      is_float(self) -> :float
      is_function(self) -> :function
      is_integer(self) -> :integer
      is_list(self) -> {:list, self}
      is_map(self) -> check_map_type(self)
      is_pid(self) -> :pid
      is_port(self) -> :port
      is_reference(self) -> :reference
      is_tuple(self) -> check_tuple_type(self)
      true -> :other
    end
  end

  defp check_map_type(field) do
    case field do
      %_{} ->
        try do
          if field.__struct__.is_valid(field) do
            field.__struct__
          else
            :error
          end
        rescue
          UndefinedFunctionError -> field.__struct__
        end

      _ ->
        :map
    end
  end

  defp check_tuple_type(field) do
    {:tuple,
     Tuple.to_list(field)
     |> Enum.map(&typeof(&1))
     |> Enum.reduce({}, &Tuple.append(&2, &1))}
  end

  def is_compatible(t1, t2) do
    case t1 do
      :number ->
        t2 == :number || t2 == :integer || t2 == :float

      :bitstring ->
        t2 == :bitstring || t2 == :binary

      :list ->
        case t2 do
          {:list, _} -> true
          _ -> false
        end

      {:list, l1_type} ->
        case t2 do
          {:list, l} -> Enum.all?(l, fn x -> l1_type == typeof(x) end)
          _ -> false
        end

      :tuple ->
        case t2 do
          {:tuple, _} -> true
          _ -> false
        end

      {:tuple, t1_types} when is_tuple(t1_types) ->
        case t2 do
          {:tuple, t2_types} when is_tuple(t2_types) ->
            l1 = Tuple.to_list(t1_types)
            l2 = Tuple.to_list(t2_types)

            length(l1) == length(l2) &&
              List.zip([l1, l2])
              |> Enum.all?(fn x -> is_compatible(elem(x, 0), elem(x, 1)) end)

          _ ->
            false
        end

      {nil, t} ->
        t2 == nil || is_compatible(t, t2)

      _ ->
        t1 == t2
    end
  end
end
