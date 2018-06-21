defmodule OptionalFieldsTest do
  use ExUnit.Case

  defmodule OptionalSimpleStruct do
    @fields %{
      s: :binary,
      n: {:number, :optional, 0}
    }

    use SafeExStruct
  end

  defmodule OptionalTupleStruct do
    @fields %{
      s: :binary,
      t1: {:tuple, :optional, {}},
      t2: {{:tuple, {:binary, :integer}}, :optional, {"a", 0}}
    }

    use SafeExStruct
  end

  defmodule OptionalListStruct do
    @fields %{
      s: :binary,
      l1: {:list, :optional, []},
      l2: {{:list, :integer}, :optional, [1, 2, 3]}
    }

    use SafeExStruct
  end

  defmodule OptionalNilStruct do
    @fields %{
      s: :binary,
      n: {:number, :optional, nil}
    }

    use SafeExStruct
  end

  test "create/1 should create a valid struct if optional fields are not specified" do
    {:ok, good_optional_struct} = OptionalSimpleStruct.create(%{s: "name"})
    assert OptionalSimpleStruct.is_valid(good_optional_struct)
  end

  test "create/1 should assign default value to optional fields if they are not specified" do
    {:ok, good_optional_struct} = OptionalSimpleStruct.create(%{s: "name"})
    assert good_optional_struct.n == 0
  end

  test "create/1 should override optional fields default value if specified" do
    {:ok, good_optional_struct} = OptionalSimpleStruct.create(%{s: "name", n: 1})
    assert good_optional_struct.n == 1
  end

  test "optional field works with fields of type tuple" do
    {:ok, good_optional_tuple_struct} = OptionalTupleStruct.create(%{s: "name"})
    assert good_optional_tuple_struct.t1 == {}
    assert good_optional_tuple_struct.t2 == {"a", 0}
    assert OptionalTupleStruct.is_valid(good_optional_tuple_struct)

    {:ok, also_good_optional_tuple_struct} =
      OptionalTupleStruct.create(%{s: "name", t1: {"hi", 1}, t2: {"b", 1}})

    assert also_good_optional_tuple_struct.t1 == {"hi", 1}
    assert also_good_optional_tuple_struct.t2 == {"b", 1}
    assert OptionalTupleStruct.is_valid(also_good_optional_tuple_struct)

    assert {:error, :invalid_args} ==
             OptionalTupleStruct.create(%{s: "name", t1: {"hi", 1}, t2: {}})
  end

  test "optional field works with fields of type list" do
    {:ok, good_optional_tuple_struct} = OptionalListStruct.create(%{s: "name"})
    assert good_optional_tuple_struct.l1 == []
    assert good_optional_tuple_struct.l2 == [1, 2, 3]
    assert OptionalListStruct.is_valid(good_optional_tuple_struct)

    {:ok, also_good_optional_tuple_struct} =
      OptionalListStruct.create(%{s: "name", l1: ["hi", 1], l2: [4, 5, 6]})

    assert also_good_optional_tuple_struct.l1 == ["hi", 1]
    assert also_good_optional_tuple_struct.l2 == [4, 5, 6]
    assert OptionalListStruct.is_valid(also_good_optional_tuple_struct)

    assert {:error, :invalid_args} ==
             OptionalListStruct.create(%{s: "name", l1: ["hi", 1], l2: [1.0, 2.0, 3.0]})
  end

  test "optional field work with nil value" do
    assert OptionalSimpleStruct.create(%{s: "name", n: nil}) == {:error, :invalid_args}
    {:ok, good_optional_tuple_struct} = OptionalNilStruct.create(%{s: "name"})
    assert OptionalNilStruct.is_valid(good_optional_tuple_struct)
    {:ok, good_optional_tuple_struct} = OptionalNilStruct.create(%{s: "name", n: nil})
    assert OptionalNilStruct.is_valid(good_optional_tuple_struct)
  end
end
