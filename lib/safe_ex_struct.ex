defmodule SafeExStruct do
  alias SafeExStruct.TypeChecker

  defmacro __using__(_opts) do
    quote do
      defstruct Map.keys(@fields)

      @fields_types @fields
                    |> Map.to_list()
                    |> Enum.map(fn x ->
                      case x do
                        {key, {t, :optional, nil}} -> {key, {nil, t}}
                        {key, {t, :optional, _}} -> {key, t}
                        t -> t
                      end
                    end)
                    |> Map.new()

      @optional_fields @fields
                       |> Map.to_list()
                       |> Enum.map(fn x ->
                         case x do
                           {key, {t, :optional, nil}} ->
                             {key, nil}

                           {key, {t, :optional, val}} ->
                             if TypeChecker.is_compatible(
                                  t,
                                  TypeChecker.typeof(val)
                                ) do
                               {key, val}
                             else
                               raise ArgumentError,
                                 message:
                                   "In module #{__MODULE__}default value #{inspect(val)} should have type #{
                                     inspect(t)
                                   }."
                             end

                           _ ->
                             nil
                         end
                       end)
                       |> Enum.filter(fn x -> x != nil end)
                       |> Map.new()

      def is_valid(x = %__MODULE__{}) do
        Map.from_struct(x)
        |> Enum.map(fn x ->
          TypeChecker.typeof(elem(x, 1))
        end)
        |> Enum.zip(Map.values(@fields_types))
        # |> IO.inspect
        |> Enum.map(fn x -> TypeChecker.is_compatible(elem(x, 1), elem(x, 0)) end)
        # |> IO.inspect
        |> Enum.concat([Map.get(x, :__struct__) == __MODULE__])
        # |> IO.inspect
        |> Enum.all?(fn x -> x == true end)
      end

      def is_valid(x) do
        raise ArgumentError,
          message: "#{inspect(x)} is not a valid #{__MODULE__} struct."
      end

      def create(x, options \\ [])

      def create(x = %{}, options) do
        ignore_unknown_fields =
          options
          |> List.keyfind(:ignore_unknown_fields, 0, {:ignore_unknown_fields, false})
          |> elem(1)

        string_key =
          options
          |> List.keyfind(:string_key, 0, {:string_key, false})
          |> elem(1)

        fields =
          cond do
            string_key ->
              for {key, val} <- x, into: %{}, do: {String.to_atom(key), val}

            true ->
              x
          end

        new_map = @optional_fields |> Map.merge(fields)

        cond do
          ignore_unknown_fields || map_size(new_map) == map_size(@fields) ->
            new_struct = struct(__MODULE__, new_map)
            # IO.inspect(new_struct)
            if is_valid(new_struct) do
              {:ok, new_struct}
            else
              {:error, :invalid_args}
            end

          true ->
            {:error, :invalid_args}
        end
      end

      def create(x, _options) do
        raise ArgumentError,
          message: "#{__MODULE__}.create/1 requires a map but found: #{inspect(x)}."
      end
    end
  end
end
