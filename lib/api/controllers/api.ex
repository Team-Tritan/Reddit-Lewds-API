defmodule Api.Controllers.APIController do
  alias Api.Helpers.{Reddit}

  def fetch_subreddit(conn, %{"subreddit" => subreddit}) do
    url = "https://www.reddit.com/r/#{subreddit}.json"
    Reddit.fetch_random_image(conn, url)
  end
end