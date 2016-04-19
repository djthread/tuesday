defmodule Tuesday.EventView do
  use Tuesday.Web, :view

  def render("show.json", %{event: event}) do
    %{id:          event.id,
      title:       event.title,
      info_json:   event.info_json,
      happens_on:  event.happens_on,
      # inserted_at: event.inserted_at,
      description: event.description,
      show_id:     event.show_id
    }
  end
end
