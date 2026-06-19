class User < ApplicationRecord
  has_secure_password

  ROLES = %w[admin project_manager developer qa client_viewer].freeze

  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships
  has_many :owned_wbs_items, class_name: "WbsItem", foreign_key: :owner_id, dependent: :nullify

  validates :name, :email, :role, presence: true
  validates :email, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, inclusion: { in: ROLES }

  before_validation { self.email = email.to_s.downcase.strip }

  def admin?
    role == "admin"
  end

  def project_role(project)
    return "admin" if admin?
    memberships.find_by(project: project)&.role
  end
end
