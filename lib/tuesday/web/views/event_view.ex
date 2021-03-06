defmodule Tuesday.Web.EventView do
  use Tuesday.Web, :view

  def render("show.json", %{event: event}) do
    %{id:           event.id,
      title:        event.title,
      happens_on:   event.happens_on,
      # inserted_at:  event.inserted_at,
      description:  event.description || "",
      show_id:      event.show_id,
      performances:
        event.info_json
        |> Poison.decode!
        |> Map.get("lines")
    }
  end

  def list(events) do
    Enum.map(events, fn(ev) ->
      render("show.json", event: ev)
    end)
  end
end
