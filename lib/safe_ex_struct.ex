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
            SafeExStruct.is_compatible(Map.get(@fields_types, elem(x,0)), elem(x, 1))
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

      @fields_types @fields |> Map.to_list |> Enum.map(fn x ->
                    case x do
                      {key, {t, :optional, _}} -> {key, t}
                      t -> t
                    end
                  end) |> Map.new

      @optional_fields @fields |> Map.to_list |> Enum.map(fn x ->
                              case x do
                                {key, {t, :optional, val}} ->
                                  if (SafeExStruct.is_compatible(t, SafeExStruct.typeof(val))) do
                                    {key, val}
                                  else
                                    raise ArgumentError,
                                      message: "In module #{__MODULE__}default value #{inspect(val)} should have type #{inspect(t)}"
                                  end
                                _ -> nil
                              end
                            end) |> Enum.filter(fn x -> x != nil end)
                            |> Map.new

      def is_valid(quote do unquote(x) end) do
        SafeExStruct.is_valid(quote do unquote(x) end)
      end

      def create(quote do unquote(x) end) do
        new_map = @optional_fields |> Map.merge(quote do unquote(x) end)
        cond do
          length(Map.keys(new_map)) == length(Map.keys(@fields)) ->
            new_struct = struct(quote do unquote(__MODULE__) end, new_map)
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
          {:tuple, t2_types} when is_tuple(t2_types) ->
            l1 = Tuple.to_list(t1_types)
            l2 = Tuple.to_list(t2_types)
            length(l1) == length(l2) && (List.zip([l1, l2])
            |> Enum.all?(fn x -> is_compatible(elem(x, 0), elem(x, 1)) end))
          _ -> false
        end
      _ -> t1 == t2
    end
  end

end
