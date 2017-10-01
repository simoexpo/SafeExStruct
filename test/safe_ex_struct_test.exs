defmodule SafeExStructTest do
  use ExUnit.Case

  defmodule SimpleStruct do

    @fields %{
      string: :binary,
      num: :integer
    }

    use SafeExStruct

  end

  defmodule NumberStruct do

    @fields %{
      num: :number
    }

    use SafeExStruct

  end

  defmodule BitstringStruct do

    @fields %{
      string: :bitstring
    }

    use SafeExStruct

  end

  defmodule ComplexStruct do

    @fields %{
      string: :binary,
      num: :number,
      other: SimpleStruct #TODO check!
    }

    use SafeExStruct

  end

  test "use SafeExStruct add to a module a struct definition based on @safe_struct map" do
    struct = %SimpleStruct{}
    assert Map.has_key?(struct, :string)
    assert Map.has_key?(struct, :num)
    assert Map.has_key?(struct, :invalid_key) == false
  end

  test "use SafeExStruct add to a module a function is_valid that can validate the defined struct" do
    good_struct = %SimpleStruct{string: "name", num: 18}
    bad_struct = %SimpleStruct{}
    assert SimpleStruct.is_valid(good_struct)
    assert SimpleStruct.is_valid(bad_struct) == false
  end

  test "use SafeExStruct add to a module a function create_struct that create a struct from a map only if it's valid" do
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

end
