defmodule SafeExStructTest do
  use ExUnit.Case
  doctest SafeExStruct

  defmodule SimpleStruct do
    require SafeExStruct

    @safe_struct %{
      string: :binary,
      num: :integer
    }

    SafeExStruct.generate
  end

  defmodule NumberStruct do
    require SafeExStruct

    @safe_struct %{
      num: :number
    }

    SafeExStruct.generate
  end

  defmodule BitstringStruct do
    require SafeExStruct

    @safe_struct %{
      string: :bitstring
    }

    SafeExStruct.generate
  end

  defmodule ComplexStruct do
    require SafeExStruct

    @safe_struct %{
      string: :binary,
      num: :number,
      other: SimpleStruct
    }

    SafeExStruct.generate
  end

  defmodule TupleStruct do
    require SafeExStruct

    @safe_struct %{
      s: :binary,
      t: {:tuple, {:binary, :integer}}
    }

    SafeExStruct.generate
  end

  test "SafeExStruct.create_struct add to a module a struct definition based on @safe_struct map" do
    struct = %SimpleStruct{}
    assert Map.has_key?(struct, :string)
    assert Map.has_key?(struct, :num)
    assert Map.has_key?(struct, :invalid_key) == false
  end

  test "SafeExStruct.create_struct add to a module a function is_valid that can validate the defined struct" do
    good_struct = %SimpleStruct{string: "name", num: 18 }
    bad_struct = %SimpleStruct{}
    assert SimpleStruct.is_valid(good_struct)
    assert SimpleStruct.is_valid(bad_struct) == false
  end

  test "SafeExStruct.create_struct add to a module a function create_struct that create a struct from a map only if it's valid" do
    good_map = %{string: "name", num: 18}
    bad_map = %{}
    assert SimpleStruct.create(good_map) == {:ok, %SimpleStruct{string: "name", num: 18}}
    assert SimpleStruct.create(bad_map) == {:error, :invalid_args}
  end

  test "is_valid should know that integer and float are number" do
    assert NumberStruct.is_valid(%NumberStruct{num: 1})
    assert NumberStruct.is_valid(%NumberStruct{num: 1.2})
  end

  test "is_valid should know that a string is a bitstring" do
    assert(BitstringStruct.is_valid(%BitstringStruct{string: "ciao"}))
  end

  test "is_valid should work with nested struct" do
    good_simple_struct = %SimpleStruct{string: "name", num: 18 }
    bad_simple_struct = %SimpleStruct{}
    good_complex_struct = %ComplexStruct{string: "name", num: 1, other: good_simple_struct}
    bad_complex_struct = %ComplexStruct{string: "name", num: 1, other: bad_simple_struct}
    assert ComplexStruct.is_valid(good_complex_struct)
    assert ComplexStruct.is_valid(bad_complex_struct) == false
  end

  test "is_valid should check types pf tuple elements" do
    good_tuple_struct = %TupleStruct{s: "s", t: {"1", 1}}
    bad_tuple_struct = %TupleStruct{s: "s", t: {1, 1}}
    assert TupleStruct.is_valid(good_tuple_struct)
    assert TupleStruct.is_valid(bad_tuple_struct) == false
  end

end
