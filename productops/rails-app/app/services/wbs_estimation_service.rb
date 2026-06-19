class WbsEstimationService
  def initialize(items)
    @items = Array(items)
  end

  def summary
    total_estimate = @items.sum { |item| item.estimated_hours.to_f }
    total_actual = @items.sum { |item| item.actual_hours.to_f }
    done = @items.count { |item| item.status == "done" }
    {
      total_tasks: @items.size,
      completed_tasks: done,
      blocked_tasks: @items.count(&:blocked?),
      overdue_tasks: @items.count(&:overdue?),
      total_estimate: total_estimate.round(2),
      total_actual: total_actual.round(2),
      variance: (total_actual - total_estimate).round(2),
      variance_percentage: total_estimate.zero? ? 0 : (((total_actual - total_estimate) / total_estimate) * 100).round(1),
      completion_percentage: @items.empty? ? 0 : ((done.to_f / @items.size) * 100).round
    }
  end
end
