defmodule SafeExStructTest do
  use ExUnit.Case
  doctest SafeExStruct

  defmodule SimpleStruct do
    @behaviour SafeExStruct
    require SafeExStruct

    @safe_struct %{
      name: :binary,
      age: :integer
    }

    SafeExStruct.create_struct
  end

  defmodule ActualStruct do
    @behaviour SafeExStruct
    require SafeExStruct

    @safe_struct %{
      name: :binary,
      age: :number,
      other: SimpleStruct
    }

    SafeExStruct.create_struct
  end

  test "SafeExStruct.create_struct add to a module a struct definition based on @safe_struct map" do
    struct = %SimpleStruct{}
    assert Map.has_key?(struct, :name)
    assert Map.has_key?(struct, :age)
    assert Map.has_key?(struct, :invalid_key) == false
  end

  test "SafeExStruct.create_struct add to a module a function is_valid that can validate the defined struct" do
    good_struct = %SimpleStruct{name: "name", age: 18 }
    bad_struct = %SimpleStruct{}
    assert SimpleStruct.is_valid(good_struct)
    assert SimpleStruct.is_valid(bad_struct) == false
  end

  test "SafeExStruct.create_struct add to a module a function create_struct that create a struct from a map only if it's valid" do
    good_map = %{name: "name", age: 18}
    bad_map = %{}
    assert SimpleStruct.create_struct(good_map) == {:ok, %SimpleStruct{name: "name", age: 18}}
    assert SimpleStruct.create_struct(bad_map) == {:error, :invalid_args}
  end

end
