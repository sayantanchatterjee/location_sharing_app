require 'test_helper'

class LocationRegistersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @location_register = location_registers(:one)
  end

  test "should get index" do
    get location_registers_url
    assert_response :success
  end

  test "should get new" do
    get new_location_register_url
    assert_response :success
  end

  test "should create location_register" do
    assert_difference('LocationRegister.count') do
      post location_registers_url, params: { location_register: { latitude: @location_register.latitude, longitude: @location_register.longitude, user_id: @location_register.user_id } }
    end

    assert_redirected_to location_register_url(LocationRegister.last)
  end

  test "should show location_register" do
    get location_register_url(@location_register)
    assert_response :success
  end

  test "should get edit" do
    get edit_location_register_url(@location_register)
    assert_response :success
  end

  test "should update location_register" do
    patch location_register_url(@location_register), params: { location_register: { latitude: @location_register.latitude, longitude: @location_register.longitude, user_id: @location_register.user_id } }
    assert_redirected_to location_register_url(@location_register)
  end

  test "should destroy location_register" do
    assert_difference('LocationRegister.count', -1) do
      delete location_register_url(@location_register)
    end

    assert_redirected_to location_registers_url
  end
end
