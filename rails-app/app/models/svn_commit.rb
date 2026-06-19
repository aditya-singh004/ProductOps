class SvnCommit < ApplicationRecord
  belongs_to :project
  belongs_to :wbs_item, optional: true

  validates :revision, :author, :committed_at, :imported_at, presence: true
  validates :revision, uniqueness: { scope: :project_id }
end
