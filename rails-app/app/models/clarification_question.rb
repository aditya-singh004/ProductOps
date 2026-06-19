class ClarificationQuestion < ApplicationRecord
  belongs_to :requirement
  belongs_to :asked_by, class_name: "User"
  belongs_to :answered_by, class_name: "User", optional: true

  validates :question, presence: true
  validates :status, inclusion: { in: %w[open answered] }
end
