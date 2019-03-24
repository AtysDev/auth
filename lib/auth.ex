defmodule Auth do
  @moduledoc false
  use Plug.Router
  alias Auth.Routes

  plug(CORSPlug)
  plug(:match)
  plug(Plug.Parsers, parsers: [:urlencoded])
  plug(:dispatch)

  post "/register" do
    Routes.Register.create(conn)
  end

  post "/confirm" do
    Routes.Confirm.create(conn)
  end

  post "/login" do
    Routes.Login.create(conn)
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
