class DependencyGraphService
  attr_reader :tasks, :dependencies

  def initialize(tasks, extra_dependency: nil)
    @tasks = Array(tasks)
    ids = @tasks.map(&:id).compact
    @dependencies = TaskDependency.where(predecessor_task_id: ids).or(TaskDependency.where(successor_task_id: ids)).to_a
    @dependencies << extra_dependency if extra_dependency
  end

  def adjacency
    @adjacency ||= begin
      graph = Hash.new { |hash, key| hash[key] = [] }
      tasks.each { |task| graph[task.id] ||= [] }
      dependencies.each do |dependency|
        graph[dependency.predecessor_task_id] << dependency.successor_task_id
      end
      graph
    end
  end

  def task_by_id
    @task_by_id ||= tasks.index_by(&:id)
  end
end
