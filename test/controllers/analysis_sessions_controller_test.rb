require "test_helper"

class AnalysisSessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get analysis_sessions_show_url
    assert_response :success
  end
end
