defmodule SafeExStruct.TypeChecker do
  # COND ORDER IS IMPORTANT!!!
  def typeof(self) do
    cond do
      is_nil(self) ->
        nil

      is_atom(self) ->
        :atom

      is_binary(self) ->
        :binary

      is_bitstring(self) ->
        :bitstring

      is_boolean(self) ->
        :boolean

      is_float(self) ->
        :float

      is_function(self) ->
        :function

      is_integer(self) ->
        :integer

      is_list(self) ->
        {:list, self}

      is_map(self) ->
        case self do
          %_{} ->
            if self.__struct__.is_valid(self) do
              self.__struct__
            else
              :error
            end

          _ ->
            :map
        end

      is_pid(self) ->
        :pid

      is_port(self) ->
        :port

      is_reference(self) ->
        :reference

      is_tuple(self) ->
        {:tuple,
         Tuple.to_list(self)
         |> Enum.map(&typeof(&1))
         |> Enum.reduce({}, &Tuple.append(&2, &1))}

      true ->
        :other
    end
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
