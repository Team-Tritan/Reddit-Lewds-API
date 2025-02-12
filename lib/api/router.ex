defmodule Api.Router do
  use Plug.Router

  alias Api.Controllers.APIController

  plug :match
  plug :dispatch

  @subreddits ["twinks", "femboys", "gayporn", "uncut_cock", "cutcocks", "straightturnedgay", "gaysnapchatshare", "barebackgayporn", "gaygifs", "totallystraight"]

  get "/api" do
    response = %{
      error: false,
      status: 200,
      endpoints: Enum.map(@subreddits, fn subreddit -> "/api/#{subreddit}" end)
    }

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(response))
  end

  for subreddit <- @subreddits do
    get "/api/#{subreddit}" do
      APIController.fetch_subreddit(conn, %{"subreddit" => unquote(subreddit)})
    end
  end

  match _ do
    response = %{
      error: true,
      status: 404,
      message: "Not found"
    }

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(404, Jason.encode!(response))
  end
end