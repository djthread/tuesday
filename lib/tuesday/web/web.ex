defmodule Tuesday.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use Tuesday.Web, :controller
      use Tuesday.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def model do
    quote do
      use Ecto.Schema

      # use Calecto.Schema, usec: true
      @timestamps_opts [type: :utc_datetime, usec: true]

      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 1, from: 2]
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, namespace: Tuesday.Web

      alias Tuesday.Repo
      import Ecto
      import Ecto.Query, only: [from: 1, from: 2]

      import Tuesday.Web.Router.Helpers
      import Tuesday.Web.Gettext
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/tuesday/web/templates",
        namespace: Tuesday.Web

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import Tuesday.Web.Router.Helpers
      import Tuesday.Web.ErrorHelpers
      import Tuesday.Web.Gettext

      alias Calendar.DateTime
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      import Ecto
      import Ecto.Query, only: [from: 1, from: 2, where: 2]
      import Tuesday.Web.Gettext
      import Tuesday.Web.Util

      alias Calendar.DateTime
      alias Tuesday.User
      alias Tuesday.Show
      alias Tuesday.Episode
      alias Tuesday.Event
      alias Tuesday.Repo

      require Logger
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
