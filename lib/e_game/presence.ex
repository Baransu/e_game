defmodule EGame.Presence do
  use Phoenix.Presence, otp_app: :my_app,
                        pubsub_server: EGame.PubSub
end
