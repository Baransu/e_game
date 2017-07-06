defmodule EGame.Web.Router do
  use EGame.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", EGame.Web do
    pipe_through :api
  end
end
