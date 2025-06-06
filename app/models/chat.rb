class Chat < ApplicationRecord
  acts_as_chat

  validates :model_id, presence: true

  ALLOWED_MODELS = [
    [ "Claude 3.5 Sonnet", "claude-3-5-sonnet" ],
    [ "GPT-4.1", "gpt-4.1" ],
    [ "Gemini 2.0 Flash", "gemini-2.0-flash" ]
  ]

  broadcasts_to ->(chat) { [ chat, "messages" ] }
end
