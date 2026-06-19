require "test_helper"

class ParserServicesTest < ActiveSupport::TestCase
  test "parses svn xml and task key" do
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <log>
        <logentry revision="1840">
          <author>dmehta</author>
          <date>2026-06-15T09:31:22.000000Z</date>
          <paths>
            <path action="A" kind="file">/trunk/db/refunds.sql</path>
          </paths>
          <msg>PO-101 create refund database migration</msg>
        </logentry>
        <logentry revision="1842">
          <author>dmehta</author>
          <date>2026-06-16T11:18:45.000000Z</date>
          <paths>
            <path action="M" kind="file">/trunk/app/controllers/refunds_controller.rb</path>
          </paths>
          <msg>PO-102 implement refund API endpoint and validations</msg>
        </logentry>
        <logentry revision="1847">
          <author>qaqiana</author>
          <date>2026-06-17T13:04:10.000000Z</date>
          <paths>
            <path action="A" kind="file">/trunk/test/refund_regression_test.rb</path>
          </paths>
          <msg>PO-105 add QA regression cases for failed transactions</msg>
        </logentry>
      </log>
    XML

    commits = SvnLogParserService.new(xml).parse

    assert_equal 3, commits.size
    assert_equal "PO-101", commits.first.task_key
    assert_equal "/trunk/db/refunds.sql", commits.first.changed_paths.first[:path]
  end

  test "parses ant success and failure logs" do
    success = AntBuildLogParserService.new("BUILD SUCCESSFUL\nTotal time: 21 seconds").parse
    failure = AntBuildLogParserService.new("FAILED test\nBUILD FAILED\nTotal time: 17 seconds").parse

    assert_equal "success", success[:status]
    assert_equal 21, success[:duration_seconds]
    assert_equal "failed", failure[:status]
    assert_operator failure[:failed_test_count], :>=, 1
  end
end
