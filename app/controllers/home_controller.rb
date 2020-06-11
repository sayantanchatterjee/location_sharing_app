class HomeController < ApplicationController
  layout "custom"
  def index
    @username = current_user.username
    @user_id = current_user.id
    @users_to_share = User.where("id <> #{current_user.id}") rescue []
    @location_registers_shared_by_self, @location_registers_shared_by_other = LocationRegister.fetch_shared_locations_by_user(@user_id)
  end

  # Method to view users list it will not include logged in user
  def users_list
    Rails.logger.info "Starting #{self}::#{__method__.to_s}"
    # Fetch the users list except the logged in users who have shared locations
    @users_list = User.fetch_other_users(current_user.id)

  end

  def show_users_public_location
    Rails.logger.info "Starting #{self}::#{__method__.to_s}"
    args = method(__method__).parameters.collect{|p| p[1].to_s}
    Rails.logger.info ("PARAMETERS RECEIVED --" + 
                        args.map{|a| "#{a} = #{eval a}"}.join(','))
    @username=params[:username]
    @publicly_shared_locations = []
    if @username.present?
      # First get the user id for the user name
      user_id = User.find_by("username = '#{@username}'").id rescue ""

      @publicly_shared_locations=LocationRegister.fetch_self_shared_location(user_id, true) rescue []
    end
  end

end
