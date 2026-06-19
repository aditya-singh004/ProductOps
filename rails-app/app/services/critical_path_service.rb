class CriticalPathService < DependencyGraphService
  def path
    sorted = TopologicalSortService.new(tasks).order
    distance = Hash.new(0)
    parent = {}

    sorted.each do |task|
      distance[task.id] = [distance[task.id], task.estimated_hours.to_f].max
      adjacency[task.id].each do |child_id|
        child = task_by_id[child_id]
        next unless child
        candidate = distance[task.id] + child.estimated_hours.to_f
        if candidate > distance[child_id]
          distance[child_id] = candidate
          parent[child_id] = task.id
        end
      end
    end

    terminal_id = distance.max_by { |_id, score| score }&.first
    return [] unless terminal_id

    ids = []
    while terminal_id
      ids.unshift(terminal_id)
      terminal_id = parent[terminal_id]
    end
    ids.map { |id| task_by_id[id] }.compact
  end
end
