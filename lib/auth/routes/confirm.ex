defmodule Auth.Routes.Confirm do
  alias Plug.Conn
  alias Auth.User
  alias Atys.Plugs.SideUnchanneler
  alias AtysApi.{Errors, Responder}
  use Plug.Builder
  require Errors

  plug(SideUnchanneler, send_after_ms: 50)
  plug(:create)
  plug(SideUnchanneler, execute: true)

  @confirm_schema %{
                    "type" => "object",
                    "properties" => %{
                      "token" => %{
                        "type" => "string"
                      }
                    },
                    "required" => ["token"]
                  }
                  |> ExJsonSchema.Schema.resolve()

  def create(%Conn{path_info: ["confirm"], method: "POST"} = conn, _opts) do
    with {:ok, conn, %{data: %{"token" => token}}} <-
           Responder.get_values(conn, @confirm_schema, frontend_request: true),
         {:ok, id} <- validate_token(token),
         :ok <- User.confirm_email(id) do
      Responder.respond(conn)
    else
      error -> Responder.handle_error(conn, error)
    end
  end

  def create(conn, _opts), do: conn

  defp validate_token(token) do
    case Sider.get(:email_tokens, token) do
      {:ok, id} -> {:ok, id}
      {:error, :missing_key} -> {:error, Errors.reason(:item_not_found)}
    end
  end
end
