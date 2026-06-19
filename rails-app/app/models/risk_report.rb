class RiskReport < ApplicationRecord
  belongs_to :project
  belongs_to :sprint, optional: true
  belongs_to :release, optional: true

  validates :risk_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :risk_level, inclusion: { in: %w[LOW MEDIUM HIGH] }
end
