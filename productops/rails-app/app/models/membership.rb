class Membership < ApplicationRecord
  belongs_to :organization
  belongs_to :project, optional: true
  belongs_to :user

  validates :role, inclusion: { in: User::ROLES }
  validates :user_id, uniqueness: { scope: %i[organization_id project_id] }
end
