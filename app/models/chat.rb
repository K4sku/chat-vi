class Chat < ApplicationRecord
  acts_as_chat

  validates :model_id, presence: true

  ALLOWED_MODELS = {
    "claude-3-5-sonnet": "Claude 3.5 Sonnet",
    "gpt-4.1": "GPT-4.1",
    "gemini-2.0-flash": "Gemini 2.0 Flash"
  }

  broadcasts_to ->(chat) { [ chat, "messages" ] }
end
