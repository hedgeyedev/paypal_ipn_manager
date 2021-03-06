defmodule Ipn.Web do
  use Plug.Router

  plug :match
  plug :dispatch

  def start_server do
    Plug.Adapters.Cowboy.http(__MODULE__, nil, port: 5454)
  end

  # The PayPal IPN calls here
  post "/payments/ipn" do
    conn
    |> Plug.Conn.send_resp(200, "")
  end

  # curl 'http://localhost:5454/entries?list=bob&date=20131219'
  get "/entries" do
    conn
    |> Plug.Conn.fetch_params
    |> fetch_entries
    |> respond
  end

  defp fetch_entries(conn) do
    Plug.Conn.assign(
      conn,
      :response,
      entries(conn.params["list"], parse_date(conn.params["date"]))
    )
  end

  defp entries(list_name, date) do
    list_name
    |> Ipn.Cache.server_process
    |> Ipn.Server.entries(date)
    |> format_entries
  end

  defp format_entries(entries) do
    for entry <- entries do
      {y,m,d} = entry.date
      "#{y}-#{m}-#{d}    #{entry.title}"
    end
    |> Enum.join("\n")
  end


  # curl -d '' 'http://localhost:5454/add_entry?list=bob&date=20131219&title=Dentist'
  post "/add_entry" do
    conn
    |> Plug.Conn.fetch_params
    |> add_entry
    |> respond
  end

  defp add_entry(conn) do
    conn.params["list"]
    |> Ipn.Cache.server_process
    |> Ipn.Server.add_entry(
          %{
            date: parse_date(conn.params["date"]),
            title: conn.params["title"]
          }
        )

    Plug.Conn.assign(conn, :response, "OK")
  end


  defp parse_date(
    # Using pattern matching to extract parts from YYYYMMDD string
    << year::binary-size(4), month::binary-size(2), day::binary-size(2) >>
  ) do
    {String.to_integer(year), String.to_integer(month), String.to_integer(day)}
  end


  defp respond(conn) do
    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, conn.assigns[:response])
  end

  # A fake PayPal acknowledgement server.  Until we start talking to a real PayPal server.
  post "/fake/acknowledge" do
    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> verified
  end

  defp verified(conn) do
    result = Ipn.FakePaypalAck.response(conn.params)
    Plug.Conn.send_resp(conn, 200, result)
  end

  match _ do
    Plug.Conn.send_resp(conn, 404, "not found")
  end
end
