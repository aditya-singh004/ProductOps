class DecisionNote < ApplicationRecord
  belongs_to :requirement
  belongs_to :decided_by, class_name: "User"

  validates :title, :decision, presence: true
end
