defmodule Api.Helpers.Reddit do
  import Plug.Conn

  def fetch_random_image(conn, url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, decoded_body} ->
            posts = decoded_body["data"]["children"]
            images = Enum.filter_map(posts, fn post -> 
              post["data"]["post_hint"] == "image" 
            end, fn post -> 
              post["data"]["url"] 
            end)
            random_image = Enum.random(images)

            case HTTPoison.get(random_image) do
              {:ok, %HTTPoison.Response{status_code: 200, body: image_body, headers: headers}} ->
                content_type = List.keyfind(headers, "Content-Type", 0, {"Content-Type", "application/octet-stream"}) |> elem(1)
                conn
                |> put_resp_content_type(content_type)
                |> send_resp(200, image_body)

              {:ok, %HTTPoison.Response{status_code: status_code}} ->
                send_error_response(conn, "Unexpected status code: #{status_code}")

              {:error, %HTTPoison.Error{reason: reason}} ->
                send_error_response(conn, "HTTP request failed: #{reason}")
            end

          {:error, _} ->
            send_error_response(conn, "Failed to decode JSON response")
        end

      {:ok, %HTTPoison.Response{status_code: 301, headers: headers}} ->
        location = List.keyfind(headers, "Location", 0, nil)
        location_url = elem(location, 1)
        send_error_response(conn, "Resource moved permanently to #{location_url}")

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        send_error_response(conn, "Unexpected status code: #{status_code}")

      {:error, %HTTPoison.Error{reason: reason}} ->
        send_error_response(conn, "HTTP request failed: #{reason}")
    end
  end

  def get_image_url(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, decoded_body} ->
            posts = decoded_body["data"]["children"]
            images = Enum.filter_map(posts, fn post -> 
              post["data"]["post_hint"] == "image" 
            end, fn post -> 
              post["data"]["url"] 
            end)
            Enum.random(images)

          {:error, _} -> nil
        end

      _ -> nil
    end
  end

  defp send_error_response(conn, message) do
    response = %{
      error: true,
      message: message
    }

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(500, Jason.encode!(response))
  end
end
