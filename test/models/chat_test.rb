require "test_helper"

class ChatTest < ActiveSupport::TestCase
  test "should not save chat without model_id" do
    chat = Chat.new
    assert_not chat.save, "Saved the chat without a model_id"
  end

  test "should save chat with valid model_id" do
    chat = Chat.new(model_id: Chat::ALLOWED_MODELS.first[1])
    assert chat.save, "Could not save the chat with a valid model_id"
  end
end
