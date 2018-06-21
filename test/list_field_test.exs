defmodule ListFieldsTest do
  use ExUnit.Case

  defmodule SimpleListStruct do
    @fields %{
      s: :binary,
      l: :list
    }

    use SafeExStruct
  end

  defmodule AdvancedListStruct do
    @fields %{
      s: :binary,
      l: {:list, :integer}
    }

    use SafeExStruct
  end

  defmodule StructAdvancedListStruct do
    @fields %{
      s: :binary,
      l: {:list, SimpleListStruct}
    }

    use SafeExStruct
  end

  test "is_valid/1 should not check types of list elements if not specified in @safe_struct" do
    good_list_struct = %SimpleListStruct{s: "s", l: ["1", 1]}
    bad_list_struct = %SimpleListStruct{s: "s", l: [1, 1]}
    assert SimpleListStruct.is_valid(good_list_struct)
    assert SimpleListStruct.is_valid(bad_list_struct)
  end

  test "is_valid/1 should check types of list elements if specified in @safe_struct" do
    good_list_struct = %AdvancedListStruct{s: "s", l: [1, 1]}
    bad_list_struct = %AdvancedListStruct{s: "s", l: ["1", 1]}
    simple_struct1 = %SimpleListStruct{s: "s1", l: [1]}
    simple_struct2 = %SimpleListStruct{s: "s2", l: [2]}
    also_good_list_struct = %StructAdvancedListStruct{s: "s", l: [simple_struct1, simple_struct2]}
    also_bad_list_struct = %StructAdvancedListStruct{s: "s", l: [simple_struct1, "1"]}
    assert AdvancedListStruct.is_valid(good_list_struct)
    assert AdvancedListStruct.is_valid(bad_list_struct) == false
    assert StructAdvancedListStruct.is_valid(also_good_list_struct)
    assert StructAdvancedListStruct.is_valid(also_bad_list_struct) == false
  end
end
