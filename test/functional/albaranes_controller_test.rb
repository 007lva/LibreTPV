require 'test_helper'

class AlbaranesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:albaranes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create albaran" do
    assert_difference('Albaran.count') do
      post :create, :albaran => { }
    end

    assert_redirected_to albaran_path(assigns(:albaran))
  end

  test "should show albaran" do
    get :show, :id => albaranes(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => albaranes(:one).to_param
    assert_response :success
  end

  test "should update albaran" do
    put :update, :id => albaranes(:one).to_param, :albaran => { }
    assert_redirected_to albaran_path(assigns(:albaran))
  end

  test "should destroy albaran" do
    assert_difference('Albaran.count', -1) do
      delete :destroy, :id => albaranes(:one).to_param
    end

    assert_redirected_to albaranes_path
  end
end
