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

  defmodule SimpleTupleStruct do
    require SafeExStruct

    @safe_struct %{
      s: :binary,
      t: :tuple
    }

    SafeExStruct.generate
  end

  defmodule AdvancedTupleStruct do
    require SafeExStruct

    @safe_struct %{
      s: :binary,
      t: {:tuple, {:binary, :integer}}
    }

    SafeExStruct.generate
  end

  test "SafeExStruct.generate/0 add to a module a struct definition based on @safe_struct map" do
    struct = %SimpleStruct{}
    assert Map.has_key?(struct, :string)
    assert Map.has_key?(struct, :num)
    assert Map.has_key?(struct, :invalid_key) == false
  end

  test "SafeExStruct.generate/0 add to a module a function is_valid that can validate the defined struct" do
    good_struct = %SimpleStruct{string: "name", num: 18 }
    bad_struct = %SimpleStruct{}
    assert SimpleStruct.is_valid(good_struct)
    assert SimpleStruct.is_valid(bad_struct) == false
  end

  test "SafeExStruct.generate/0 add to a module a function create_struct that create a struct from a map only if it's valid" do
    good_map = %{string: "name", num: 18}
    bad_map = %{string: "name"}
    also_bad_map = %{string: "name", num: 18, badkey: nil}
    assert SimpleStruct.create(good_map) == {:ok, %SimpleStruct{string: "name", num: 18}}
    assert SimpleStruct.create(bad_map) == {:error, :invalid_args}
    assert SimpleStruct.create(also_bad_map) == {:error, :invalid_args}
  end

  test "is_valid/1 should know that integer and float are number" do
    assert NumberStruct.is_valid(%NumberStruct{num: 1})
    assert NumberStruct.is_valid(%NumberStruct{num: 1.2})
  end

  test "is_valid/1 should know that a string is a bitstring" do
    assert(BitstringStruct.is_valid(%BitstringStruct{string: "ciao"}))
  end

  test "is_valid/1 should work with nested struct" do
    good_simple_struct = %SimpleStruct{string: "name", num: 18 }
    bad_simple_struct = %SimpleStruct{}
    good_complex_struct = %ComplexStruct{string: "name", num: 1, other: good_simple_struct}
    bad_complex_struct = %ComplexStruct{string: "name", num: 1, other: bad_simple_struct}
    assert ComplexStruct.is_valid(good_complex_struct)
    assert ComplexStruct.is_valid(bad_complex_struct) == false
  end

  test "is_valid/1 should check types of tuple elements if specified in @safe_struct" do
    good_tuple_struct = %AdvancedTupleStruct{s: "s", t: {"1", 1}}
    bad_tuple_struct = %AdvancedTupleStruct{s: "s", t: {1, 1}}
    assert AdvancedTupleStruct.is_valid(good_tuple_struct)
    assert AdvancedTupleStruct.is_valid(bad_tuple_struct) == false
  end

  test "is_valid/1 should not check types pf tuple elements if not specified in @safe_struct" do
    good_tuple_struct = %SimpleTupleStruct{s: "s", t: {"1", 1}}
    bad_tuple_struct = %SimpleTupleStruct{s: "s", t: {1, 1}}
    assert SimpleTupleStruct.is_valid(good_tuple_struct)
    assert SimpleTupleStruct.is_valid(bad_tuple_struct)
  end

end
