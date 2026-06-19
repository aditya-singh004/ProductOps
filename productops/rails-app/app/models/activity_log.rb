class ActivityLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :project, optional: true

  validates :entity_type, :action, presence: true
end
