defmodule SafeExStruct do

  defmacro is_valid(x) do
    quote do
      unquote(
        quote do
          Map.from_struct(unquote(x))
          |> Enum.map(fn x ->
            {elem(x, 0), SafeExStruct.typeof(elem(x,1))}
          end)
          #|> IO.inspect
          |> Enum.map(fn x ->
            SafeExStruct.is_compatible(Map.get(@fields, elem(x,0)), elem(x, 1))
          end)
          #|> IO.inspect
          |> Enum.concat([Map.get(unquote(x), :__struct__) == quote do unquote(__MODULE__) end])
          #|> IO.inspect
          |> Enum.all?(fn x -> x == true end)
        end
      )
    end
  end

  defmacro generate do
    quote do
      defstruct Map.keys(@fields)

      def is_valid(quote do unquote(x) end) do
        SafeExStruct.is_valid(quote do unquote(x) end)
      end

      def create(quote do unquote(x) end) do
        cond do
          length(Map.keys(quote do unquote(x) end)) == length(Map.keys(@fields)) ->
            new_struct = struct(quote do unquote(__MODULE__) end, quote do unquote(x) end)
            if is_valid(new_struct) do
              {:ok, new_struct}
            else
              {:error, :invalid_args}
            end
          true ->
            {:error, :invalid_args}
        end
      end
    end
  end

  def typeof(self) do
    cond do
      is_atom(self)       -> :atom
      is_bitstring(self)  -> cond do
                                is_binary(self) -> :binary
                                true            -> :bitstring
                             end
      is_boolean(self)    -> :boolean
      is_float(self)      -> :float
      is_function(self)   -> :function
      is_integer(self)    -> :integer
      is_list(self)       -> {:list, self}
      is_map(self)        -> case self do
                                %_{} -> if self.__struct__.is_valid(self) do
                                          self.__struct__
                                        else
                                          :error
                                        end
                                _ -> :map
                             end
      is_nil(self)        -> :nil
      is_pid(self)        -> :pid
      is_port(self)       -> :port
      is_reference(self)  -> :reference
      is_tuple(self)      -> {:tuple, Tuple.to_list(self)
                             |> Enum.map(&typeof(&1))
                             |> Enum.reduce({}, &Tuple.append(&2, &1))}
      true                -> :other
    end
  end

  def is_compatible(t1,t2) do
    case t1 do
      :number     -> t2 == :number || t2 == :integer || t2 == :float
      :bitstring  -> t2 == :bitstring || t2 == :binary
      :list       ->
        case t2 do
          {:list, _} -> true
          _ -> false
        end
      {:list, l1_type} ->
        case t2 do
          {:list, l} -> Enum.all?(l, fn x -> l1_type == typeof(x) end)
          _ -> false
        end
      :tuple      ->
        case t2 do
          {:tuple, _} -> true
          _ -> false
        end
      {:tuple, t1_types} when is_tuple(t1_types) ->
        case t2 do
          {:tuple, t2_types} when is_tuple(t1_types) ->
            List.zip([Tuple.to_list(t1_types), Tuple.to_list(t2_types)])
            |> Enum.all?(fn x -> is_compatible(elem(x, 0), elem(x, 1)) end)
          _ -> false
        end
      _ -> t1 == t2
    end
  end

end
