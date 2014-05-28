require 'faye/websocket'

app = lambda do |env|
  case env['PATH_INFO']
  when '/'
    Rack::File.new('public/index.html').call(env)

  when '/websocket'
    pp env
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
    Rack::Directory.new("public").call(env)
  end
end

run app
