class AntBuildLogParserService
  def initialize(log_output)
    @log_output = log_output.to_s
  end

  def parse
    {
      status: @log_output.match?(/BUILD SUCCESSFUL/i) ? "success" : "failed",
      duration_seconds: duration_seconds,
      failed_test_count: failed_test_count,
      log_output: @log_output,
      executed_at: Time.current
    }
  end

  private

  def duration_seconds
    if (match = @log_output.match(/Total time:\s*(\d+)\s*seconds?/i))
      match[1].to_i
    elsif (match = @log_output.match(/Total time:\s*(\d+)\s*minutes?\s*(\d+)\s*seconds?/i))
      (match[1].to_i * 60) + match[2].to_i
    else
      0
    end
  end

  def failed_test_count
    @log_output.scan(/FAILED|failure|error/i).size
  end
end
