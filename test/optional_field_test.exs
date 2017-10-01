defmodule OptionalFieldsTest do
  use ExUnit.Case

  defmodule OptionalSimpleStruct do
    require SafeExStruct

    @fields %{
      s: :binary,
      n: {:number, :optional, 0}
    }

    SafeExStruct.generate
  end

  test "create/1 should create a valid struct if optional fields are not specified" do
    {:ok, good_optional_struct} = OptionalSimpleStruct.create(%{s: "namezz"})
    assert OptionalSimpleStruct.is_valid(good_optional_struct)
  end

  test "create/1 should assign default value to optional fields if they are not specified" do
    {:ok, good_optional_struct} = OptionalSimpleStruct.create(%{s: "namezz"})
    assert good_optional_struct.n == 0
  end

  test "create/1 should override optional fields default value if specified" do
    {:ok, good_optional_struct} = OptionalSimpleStruct.create(%{s: "namezz", n: 1})
    assert good_optional_struct.n == 1
  end

end
