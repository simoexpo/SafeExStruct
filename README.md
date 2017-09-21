# SafeExStruct [![Build Status](https://travis-ci.org/simoexpo/SafeExStruct.svg?branch=master)](https://travis-ci.org/simoexpo/SafeExStruct?branch=master) [![Coverage Status](https://coveralls.io/repos/github/simoexpo/SafeExStruct/badge.svg?branch=master)](https://coveralls.io/github/simoexpo/SafeExStruct?branch=master)

## In progress

SafeExStruct help to create and validate struct in elixir defining functions to assist the creation of a struct and check its validity.

To define a struct you need to create a module and define a map `@safe_struct` of `key` and `type`.

```elixir
@safe_struct %{
    string: :binary,
    num: :integer
 }
```

You can then call the function `SafeExStruct.generate` to add via macro the struct definition and 2 functions:
* `is_valid`
* `create`

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `safeexstruct` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:safeexstruct, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/struct_checker](https://hexdocs.pm/struct_checker).
