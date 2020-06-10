require "application_system_test_case"

class LocationRegistersTest < ApplicationSystemTestCase
  setup do
    @location_register = location_registers(:one)
  end

  test "visiting the index" do
    visit location_registers_url
    assert_selector "h1", text: "Location Registers"
  end

  test "creating a Location register" do
    visit location_registers_url
    click_on "New Location Register"

    fill_in "Latitude", with: @location_register.latitude
    fill_in "Longitude", with: @location_register.longitude
    fill_in "User", with: @location_register.user_id
    click_on "Create Location register"

    assert_text "Location register was successfully created"
    click_on "Back"
  end

  test "updating a Location register" do
    visit location_registers_url
    click_on "Edit", match: :first

    fill_in "Latitude", with: @location_register.latitude
    fill_in "Longitude", with: @location_register.longitude
    fill_in "User", with: @location_register.user_id
    click_on "Update Location register"

    assert_text "Location register was successfully updated"
    click_on "Back"
  end

  test "destroying a Location register" do
    visit location_registers_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Location register was successfully destroyed"
  end
end
