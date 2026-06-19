class TopologicalSortService < DependencyGraphService
  def order
    indegree = Hash.new(0)
    adjacency.each_key { |node| indegree[node] = 0 unless indegree.key?(node) }
    adjacency.each_value { |children| children.each { |child| indegree[child] += 1 } }
    queue = indegree.select { |_node, count| count.zero? }.map(&:first)
    sorted = []

    until queue.empty?
      node = queue.shift
      sorted << task_by_id[node] if task_by_id[node]
      adjacency[node].each do |child|
        indegree[child] -= 1
        queue << child if indegree[child].zero?
      end
    end

    sorted
  end
end
