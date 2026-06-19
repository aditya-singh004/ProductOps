require "net/http"
require "json"

class RiskEngineClient
  class Unavailable < StandardError; end

  def initialize(base_url: ENV.fetch("RISK_ENGINE_URL", "http://risk-engine-service:8080"))
    @base_url = base_url
  end

  def calculate(sprint:, release: nil)
    uri = URI.join(@base_url, "/api/risk/calculate")
    request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
    request.body = payload_for(sprint, release).to_json
    response = Net::HTTP.start(uri.hostname, uri.port, read_timeout: 5, open_timeout: 2) do |http|
      http.request(request)
    end
    raise Unavailable, response.body unless response.is_a?(Net::HTTPSuccess)
    JSON.parse(response.body)
  rescue SocketError, Errno::ECONNREFUSED, Net::OpenTimeout, Net::ReadTimeout => e
    raise Unavailable, e.message
  end

  def payload_for(sprint, release)
    critical_ids = CriticalPathService.new(sprint.wbs_items.includes(:incoming_dependencies).to_a).path.map(&:id)
    {
      sprintId: sprint.id,
      releaseId: release&.id,
      criticalPathTaskIds: critical_ids,
      tasks: sprint.wbs_items.map do |task|
        {
          id: task.id,
          title: task.title,
          estimateHours: task.estimated_hours.to_f,
          actualHours: task.actual_hours.to_f,
          status: task.status.upcase,
          priority: task.requirement.priority.upcase,
          blocked: task.blocked?,
          overdue: task.overdue?,
          dependencies: task.predecessor_tasks.pluck(:id)
        }
      end
    }
  end
end
