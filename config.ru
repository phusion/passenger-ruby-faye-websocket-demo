require 'faye/websocket'

app = lambda do |env|
  if env['PATH_INFO'] == '/websocket'
    ws = Faye::WebSocket.new(env)

    timer = EM.add_periodic_timer(1) do
      ws.send(Time.now.to_s)
    end

    ws.on :message do |event|
      ws.send("You sent: #{event.data}")
    end

    ws.on :close do |event|
      EM.cancel_timer(timer)
      ws = nil
    end

    # Return async Rack response
    ws.rack_response

  else
    [404, { "Content-Type" => "text/plain" }, ["Not found"]]
  end
end

# See https://www.phusionpassenger.com/library/config/tuning_sse_and_websockets/
if defined?(PhusionPassenger)
  PhusionPassenger.advertised_concurrency_level = 0
end

run app
