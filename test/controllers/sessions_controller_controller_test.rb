require 'test_helper'

class SessionsControllerControllerTest < ActionController::TestCase
  test "should get login" do
    get :login
    assert_response :success
  end

  test "should get lougout" do
    get :lougout
    assert_response :success
  end

end
