class CycleDetectionService < DependencyGraphService
  def cycle?
    visiting = {}
    visited = {}

    adjacency.keys.any? do |node|
      dfs_cycle?(node, visiting, visited)
    end
  end

  private

  def dfs_cycle?(node, visiting, visited)
    return true if visiting[node]
    return false if visited[node]

    visiting[node] = true
    adjacency[node].any? { |child| dfs_cycle?(child, visiting, visited) }.tap do
      visiting.delete(node)
      visited[node] = true
    end
  end
end
