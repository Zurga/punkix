defmodule <%= @web_namespace %>.RoutexBackend do
  use Routex.Backend,
    extensions: [
      # required
      Routex.Extension.AttrGetters,

      # adviced
      Routex.Extension.LiveViewHooks,
      Routex.Extension.Plugs,
      Routex.Extension.VerifiedRoutes,
      Routex.Extension.Alternatives,
      Routex.Extension.AlternativeGetters,
      Routex.Extension.Assigns,
      Routex.Extension.Localize.Phoenix.Routes,
      Routex.Extension.Localize.Phoenix.Runtime,
      Routex.Extension.RuntimeDispatcher,

      # optional
      # when you want translated routes
      Routex.Extension.Translations,
      # Routex.Extension.Interpolation, # when path prefixes don't cut it
      # Routex.Extension.RouteHelpers,  # when verified routes can't be used
      # when combined with the Cldr ecosystem
      # Routex.Extension.Cldr
    ],
    assigns: %{namespace: :rtx, attrs: [:locale, :language, :region]},
    verified_sigil_routex: "~p",
    verified_sigil_phoenix: "~o",
    verified_url_routex: :url,
    verified_path_routex: :path
end
