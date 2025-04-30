class Chat < ApplicationRecord
  acts_as_chat

  validates :model_id, presence: true
end
