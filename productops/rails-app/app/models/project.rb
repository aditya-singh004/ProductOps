class Project < ApplicationRecord
  belongs_to :organization
  has_many :memberships, dependent: :destroy
  has_many :requirements, dependent: :destroy
  has_many :sprints, dependent: :destroy
  has_many :releases, dependent: :destroy
  has_many :meeting_notes, dependent: :destroy
  has_many :svn_commits, dependent: :destroy
  has_many :build_runs, dependent: :destroy
  has_many :activity_logs, dependent: :nullify

  validates :name, :key, presence: true
  validates :key, uniqueness: { scope: :organization_id }

  scope :active, -> { where(deleted_at: nil) }
end
