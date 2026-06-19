class BlockerPropagationService < DependencyGraphService
  def at_risk_tasks
    blocked_ids = tasks.select(&:blocked?).map(&:id)
    risk_ids = []
    queue = blocked_ids.dup

    until queue.empty?
      node = queue.shift
      adjacency[node].each do |child|
        next if risk_ids.include?(child)
        risk_ids << child
        queue << child
      end
    end

    risk_ids.map { |id| task_by_id[id] }.compact
  end
end
