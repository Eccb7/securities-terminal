class MarketChannel < ApplicationCable::Channel
  def subscribed
    # Stream from the market channel
    stream_from "market_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end

  def follow(data)
    # Allow users to follow specific securities
    security_id = data["security_id"]
    stream_from "market_channel_security_#{security_id}"
  end

  def unfollow(data)
    # Stop following a specific security
    security_id = data["security_id"]
    stop_stream_from "market_channel_security_#{security_id}"
  end
end
