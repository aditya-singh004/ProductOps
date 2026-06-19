ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/reporters"

Minitest::Reporters.use!

class ActiveSupport::TestCase
  parallelize(workers: 1)

  def demo_user(role = "admin")
    User.create!(name: role.titleize, email: "#{role}-#{SecureRandom.hex(4)}@example.com", password: "password123", role: role)
  end

  def demo_project
    org = Organization.create!(name: "Test Org #{SecureRandom.hex(3)}")
    project = org.projects.create!(name: "Test Project", key: "TP#{SecureRandom.random_number(1000)}")
    [org, project]
  end

  def demo_requirement(project, user)
    project.requirements.create!(title: "Requirement", description: "Details", priority: "high", status: "ready_for_estimation", created_by: user, assigned_owner: user)
  end
end
