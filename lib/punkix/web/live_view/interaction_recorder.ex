defmodule Punkix.Web.Components.InteractionRecorder do
  use Surface.LiveView

  alias Surface.Components.Form
  alias Surface.Components.Form.{Field, HiddenInput, Select, TextInput, Inputs}

  data(recording?, :boolean)
  data(recordings, :map, default: %{})
  data(current_url, :string)
  data(url_params, :list)

  defmodule Recording do
    use Ecto.Schema
    import Ecto.Changeset

    embedded_schema do
      field(:url, :string)
      field(:name, :string)

      embeds_many :url_params, UrlParams do
        field(:selector, :string)
        field(:value, :string)
      end
    end

    def changeset(url_schema, params \\ %{}) do
      url_schema
      |> cast(params, [:url])
      |> cast_embed(:url_params,
        with: fn changeset, params ->
          cast(changeset, params, [:selector, :value])
        end
      )
    end
  end

  def mount(_params, _session, socket) do
    routes =
      Phoenix.Router.routes(socket.router)
      |> Enum.map(&Map.get(&1, :path))

    {:ok,
     assign(socket,
       recording?: false,
       current_url: nil,
       recordings: %{},
       routes: routes,
       url_params: []
     )
     |> assign_form(%{
       "url" => ""
     })}
  end

  @impl true
  def render(assigns) do
    ~F"""
      <div id="interaction_recorder" :hook>
        <div class="toolbar">
           <Form :let={form: form} for={@form} submit={@recording? && "stop-recording" || "start-recording"} change="change">
            <Field name={:name}>
              <TextInput />
            </Field>
            <Field name={:url}>
              <Select options={@routes} />
            </Field>
            <Inputs for={:url_params} :let={form: param_form}>
                <label>{param_form[:label].value}</label>
                <HiddenInput field={:selector} />
                <Field name={:value}>
                  <TextInput />
                </Field>
            </Inputs>
            <button type="submit">{@recording? && "Stop" || "Start"} recording</button>
           </Form>
        </div>
      </div>
    """
  end

  @impl true
  def handle_event("change", %{"url_schema" => %{"url" => url} = params}, socket) do
    path_params =
      Regex.scan(~r/:([\w_]+)/, url)
      |> Enum.map(fn [selector, label] ->
        value =
          params
          |> Map.get("url_params", [])
          |> Enum.map(&elem(&1, 1))
          |> Enum.find(%{}, &(Map.get(&1, "selector") == selector))
          |> Map.get("value")

        %{"label" => label, "selector" => selector, "value" => value}
      end)

    params =
      Map.put(params, "url_params", path_params)

    {:noreply, assign_form(socket, params)}
  end

  @impl true
  def handle_event("start-recording", %{"url_schema" => %{"url" => url} = params}, socket) do
    %{router: router, endpoint: endpoint} = socket

    %{plug: module} = Phoenix.Router.route_info(router, "GET", url, endpoint.host())
    path = Recording.changeset(%Recording{}, params) |> Ecto.Changeset.apply_changes()

    current_url =
      path.url_params
      |> Enum.reduce(url, fn %{selector: selector, value: value}, acc ->
        Regex.replace(~r/#{selector}/, acc, value, global: false)
      end)
      |> then(fn url ->
        URI.append_path(URI.parse(endpoint.url()), url) |> URI.to_string()
      end)

    recordings = socket.assigns.recordings
    # |> Map.put(module, %{

    {:noreply,
     push_event(socket, "start-recording", %{module: module, path: current_url})
     |> assign(current_url: current_url, recording?: true)}
  end

  @impl true
  def handle_event("stop-recording", _, socket) do
    {:noreply,
     socket
     |> assign(recording?: false)
     |> push_event("stop-recording", %{})}
  end

  @impl true
  def handle_event(
        "record-interaction",
        %{"name" => name, "interaction" => interaction},
        socket
      ) do
    recordings =
      Map.update(socket.assigns.recordings, name, [interaction], fn interactions ->
        interactions ++ [interaction]
      end)

    {:noreply, assign(socket, recordings: recordings)}
  end

  defp assign_form(socket, params) do
    assign(socket, form: to_form(Recording.changeset(%Recording{}, params)))
  end
end
