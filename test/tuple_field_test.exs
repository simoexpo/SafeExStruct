defmodule TupleFieldsTest do
  use ExUnit.Case

  defmodule SimpleTupleStruct do

    @fields %{
      s: :binary,
      t: :tuple
    }
    use SafeExStruct

  end

  defmodule AdvancedTupleStruct do

    @fields %{
      s: :binary,
      t: {:tuple, {:binary, :integer}}
    }
    use SafeExStruct
    
  end

  test "is_valid/1 should check types of tuple elements if specified in @safe_struct" do
    good_tuple_struct = %AdvancedTupleStruct{s: "s", t: {"1", 1}}
    bad_tuple_struct = %AdvancedTupleStruct{s: "s", t: {1, 1}}
    assert AdvancedTupleStruct.is_valid(good_tuple_struct)
    assert AdvancedTupleStruct.is_valid(bad_tuple_struct) == false
  end

  test "is_valid/1 should not check types of tuple elements if not specified in @safe_struct" do
    good_tuple_struct = %SimpleTupleStruct{s: "s", t: {"1", 1}}
    bad_tuple_struct = %SimpleTupleStruct{s: "s", t: {1, 1}}
    assert SimpleTupleStruct.is_valid(good_tuple_struct)
    assert SimpleTupleStruct.is_valid(bad_tuple_struct)
  end

end
