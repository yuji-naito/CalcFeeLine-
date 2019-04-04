require 'test_helper'

class CalcLinesControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get calc_lines_home_url
    assert_response :success
  end

end
