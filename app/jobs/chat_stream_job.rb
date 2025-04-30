# frozen_string_literal: false

class ChatStreamJob < ApplicationJob
  queue_as :default

  def perform(chat, user_message)
    full_response = ""

    chat.ask(user_message) do |chunk|
      full_response << (chunk.content || "".freeze)

      # Get the latest (assistant) message record, which was created by `ask`
      assistant_message = chat.messages.last
      if chunk.content && assistant_message
        # Append the chunk content to the message's target div
        assistant_message.broadcast_append_chunk(chunk.content)
      end
    end

    # Optionally broadcast a final state or confirmation
  end
end
