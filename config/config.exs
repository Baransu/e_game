# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :e_game,
  ecto_repos: [EGame.Repo]

# Configures the endpoint
config :e_game, EGame.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "aEAv6W22pZcUFAyhjn1vU7yIuo6eWUG6SZZalUNJNVzFt7wvSn1c0W6Km6bKZ0iA",
  render_errors: [view: EGame.Web.ErrorView, accepts: ~w(json)],
  pubsub: [name: EGame.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
