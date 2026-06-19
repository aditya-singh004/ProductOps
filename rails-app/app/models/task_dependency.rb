class TaskDependency < ApplicationRecord
  TYPES = %w[blocks related required_before].freeze

  belongs_to :predecessor_task, class_name: "WbsItem"
  belongs_to :successor_task, class_name: "WbsItem"

  validates :dependency_type, inclusion: { in: TYPES }
  validates :successor_task_id, uniqueness: { scope: :predecessor_task_id }
  validate :no_self_dependency
  validate :no_cycle

  private

  def no_self_dependency
    errors.add(:successor_task, "cannot depend on itself") if predecessor_task_id == successor_task_id
  end

  def no_cycle
    return if predecessor_task.blank? || successor_task.blank?
    project = predecessor_task.requirement.project
    tasks = WbsItem.joins(:requirement).where(requirements: { project_id: project.id }).to_a
    candidate = self
    service = CycleDetectionService.new(tasks, extra_dependency: candidate)
    errors.add(:base, "dependency creates a cycle") if service.cycle?
  end
end
