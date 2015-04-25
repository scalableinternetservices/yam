require 'test_helper'

class Game2048ControllerTest < ActionController::TestCase
  test "should get move" do
    get :move
    assert_response :success
  end

  test "should get place" do
    get :place
    assert_response :success
  end

end
