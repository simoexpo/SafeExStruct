# SafeExStruct [![Build Status](https://travis-ci.org/simoexpo/SafeExStruct.svg?branch=master)](https://travis-ci.org/simoexpo/SafeExStruct?branch=master) [![Coverage Status](https://coveralls.io/repos/github/simoexpo/SafeExStruct/badge.svg?branch=master)](https://coveralls.io/github/simoexpo/SafeExStruct?branch=master)

## What is it?

SafeExStruct is a small library that provides help to **create** and **validate typed struct** in elixir.

## How does it work?

SafeExStruct uses *macro* to define functions to assist the creation of a struct and check its validity. It requires the user to define a map (`@fields`) containing the struct fields with their relative types and then with the invocation of a single function (`SafeExStruct.generate/0`) it will automatically generate the struct and all the usefull fucntions.

### Module definition:

```elixir
defmodule SimpleStruct do
    require SafeExStruct

    @fields %{
      string: :binary,
      num: :integer
    }

    SafeExStruct.generate
end
```

Explanation:
* `require SafeExStruct` needs to be specified to access the `SafeExStruct` macro.
* `@fields` define the struct with a map `field_name -> field_type`.
* `SafeExStruct.generate` add the creation and validation functions to the module.

### Generated functions:

* `is_valid(struct) :: boolean`: returns true if the struct is valid, i.e. if its fields types are the same of the fields types defined in `@fields`.
* `create(map) :: {:ok, struct} | {:error, :invalid_args}`: creates a type-safe struct given a map `field_name -> value` or return an error if at least one of the given value doesn't suite the field type defined in `@fields`.

```elixir
SimpleStruct.is_valid(%SimpleStruct{string: "name", num: 1})      # -> true
SimpleStruct.is_valid(%SimpleStruct{string: "name", num: 1.0})    # -> false

SimpleStruct.create(%{string: "name", num: 1})    # -> {:ok, %SimpleStruct{string: "simple", num: 1}}
SimpleStruct.create(%{string: "name", num: 1.0})  # -> {:error, :invalid_args}
```

### Available types:

* atom -> `:atom`
* bitstring -> `:bitstring`
* boolean -> `:boolean`
* float -> `:float`
* function -> `:function`
* integer -> `:integer`
* list -> `:list` | `{:list, elem_type}`
* map -> `:map`
* number -> `:number`
* nil -> `:nil`
* pid -> `:pid`
* port -> `:port`
* reference -> `:reference`
* struct -> `__MODULE__` of struct.
* tuple -> `:tuple` | `{:tuple, tuple_of_types_of_tuple_elem`}

## Examples

#### Simple struct:
```elixir
defmodule SimpleStruct do
    require SafeExStruct

    @fields %{
      string: :binary,
      num: :integer
    }

    SafeExStruct.generate
end
```
Define a struct with two fields `string` and `num` respectively of type `binary` and `integer`.

#### Struct-field struct:
```elixir
defmodule StructFieldStruct do
    require SafeExStruct

    @fields %{
      string: :binary,
      num: :integer,
      struct: SimpleStruct
    }

    SafeExStruct.generate
end
```
Define a struct with three fields `string`, `num` and `struct` respectively of type `binary` and `integer` and `SimpleStruct`.

#### List-field struct without list type:
```elixir
defmodule SimpleListStruct do
    require SafeExStruct

    @fields %{
      s: :binary,
      l: :list
    }

    SafeExStruct.generate
end
```
Define a struct with two fields `s` and `l` respectively of type `binary` and `list` without specify the list elements type.

#### List-field struct with list type:
```elixir
defmodule AdvancedListStruct do
    require SafeExStruct

    @fields %{
      s: :binary,
      l: {:list, :integer}
    }

    SafeExStruct.generate
end
```
Define a struct with two fields `s` and `l` respectively of type `binary` and `list` with `integer` elements.

#### Tuple-field struct without type:
```elixir
defmodule SimpleTupleStruct do
    require SafeExStruct

    @fields %{
      s: :binary,
      t: :tuple
    }

    SafeExStruct.generate
end
```
Define a struct with two fields `s` and `t` respectively of type `binary` and `tuple` without specify the tuple elements types.

#### Tuple-field struct with type:
```elixir
defmodule AdvancedTupleStruct do
    require SafeExStruct

    @fields %{
      s: :binary,
      t: {:tuple, {:binary, :integer}}
    }

    SafeExStruct.generate
end
```
Define a struct with two fields `s` and `t` respectively of type `binary` and `tuple`. The tuple should have two elements respectively of type `binary` and `integer`.

#### Optional-field struct
```elixir
defmodule OptionalSimpleStruct do
    require SafeExStruct

    @fields %{
      s: :binary,
      n: {:number, :optional, 0}
    }

    SafeExStruct.generate
end
```
Define a struct with a mandatory field `s` of type `binary` and an optional field `n` of type `number` with defualt value `0`.

## Installation

```elixir
def deps do
  [
    {:safeexstruct, git: "git://github.com/simoexpo/SafeExStruct.git"}
  ]
end
```
