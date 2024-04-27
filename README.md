# Punkix

An opionated Phoenix installer and generator. It uses Surface as the templating engine, 
does not use Tailwind and has basic semantic html in the generated components. The generators
re-use as much of the code that the Phoenix generators as possible to ease mainainability.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `punkix` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:punkix, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/punkix>.

TODO Installer
- [x] set correct deps
- [x] use Punkix.Repo
- [x] remove all Tailwind
- [x] create end-to-end Test

TODO WEB
- [ ] Change inputs
- [ ] Add FormComponent abstraction
- [ ] Add changeset validation in FormComponent
- [ ] Make index/show pages subscribe to PubSub events

TODO Context
- [ ] VBT style core functions for modifying data
- [ ] Optional pubsub hook
- [x] remove changeset from schema
 
TODO Generators
- [ ] phx.gen.auth
- [x] phx.gen.context
- [ ] phx.gen.html
- [x] phx.gen.live
- [x] phx.gen.schema
- [ ] phx.gen.embedded
- [ ] phx.gen.notifier
- [ ] phx.gen.socket
