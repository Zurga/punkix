defmodule Punkix.Web.LayoutView do
  use Phoenix.Template,
    namespace: Punkix.Web,
    root: "lib/punkix/web/templates"

  import Surface

  def render(_, assigns) do
    ~F"""
    <html lang="en">
      <head>
        <meta name="csrf-token" content={Phoenix.Controller.get_csrf_token()}>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="initial-scale=1, maximum-scale=1, minimum-scale=1">
        <title>Component Catalogue</title>
        <link rel="icon" href="data:,">
        <link phx-track-static rel="stylesheet" href="/assets/app.css" }>
        <script defer phx-track-static type="text/javascript" src="assets/app.js" } />
      </head>
      <body>
        {@inner_content}
      </body>
    </html>
    """
  end
end
