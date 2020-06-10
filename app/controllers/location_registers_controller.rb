class LocationRegistersController < ApplicationController
  
    # Open show locations
    def index
        @longitude= params[:longitude]
        @latitude= params[:latitude]

        Rails.logger.debug "@longitude ====== #{@longitude}------ #{@latitude}"
        
        render layout: false
    end

    # Method for opening share location page
    def share_location
        Rails.logger.info "Starting #{self}::#{__method__.to_s}"
        # render layout: false
    end 

    # destroy locations and dependent records from shared location mappings
    def destroy_location
        Rails.logger.info "Starting #{self}::#{__method__.to_s}"
        args = method(__method__).parameters.collect{|p| p[1].to_s}
        Rails.logger.info "PARAMETERS RECEIVED --" + args.map{|a| "#{a} = #{eval a}"}.join(',')
        location_id = params[:location_id].to_i rescue 0
        # Check for valid location id (>0)
        reponse_message = ""
        if location_id > 0
            # Call for delete locations from location register and also from
            # mapping table for that location
            begin
              LocationRegister.find(location_id).destroy
              reponse_message = "Deletion Successfull"
            rescue Exception => error
              Rails.logger.info "Exception in destroying location with id:#{location_id}"
              reponse_message = "Deletion Failed"
            end
        else
          reponse_message = "Deletion Failed! Provide a valid location id"
        end
        render :plain => reponse_message
    end

    # Method to save new location for current logged in user
    def save_new_location
        Rails.logger.info "Starting #{self}::#{__method__.to_s}"
        args = method(__method__).parameters.collect{|p| p[1].to_s}
        Rails.logger.info "PARAMETERS RECEIVED --" + args.map{|a| "#{a} = #{eval a}"}.join(',')
        curren_user_id = current_user.id rescue ""
        latitude = params[:latitude] rescue ""
        longitude = params[:longitude] rescue ""
        reponse_message = "Save Location Failed"
        if curren_user_id.present? && latitude.present? && longitude.present?
            # Call for save records in location register
            location_id, reponse_message = LocationRegister.insert_location_data(latitude, 
                                                      longitude, curren_user_id) rescue 0
            # Call for update the mapping table also... As by default location will be 
            # visible as public location
            # Before calling to update shared mapping table checking the status of location
            # save by checking the returned location id (>0) which will required to update the
            # mapping table 
            if location_id > 0
                update_status_str = SharedLocationMapping.update_location_mapping_data(location_id,
                                                                      []) rescue "Sharing failed"
                # Update update the response string to show the message
                if update_status_str != "Sharing failed"
                    reponse_message = "Location saved successfully and shared publicly"
                end
            end
          end
          render :plain => reponse_message
    end
    
    # Ajax method to update sharing information in shared location mapping table
    def update_location_share
        Rails.logger.info "Starting #{self}::#{__method__.to_s}"
        args = method(__method__).parameters.collect{|p| p[1].to_s}
        Rails.logger.info "PARAMETERS RECEIVED --" + args.map{|a| "#{a} = #{eval a}"}.join(',')
        location_id = params[:location_id]
        user_id_arr = params[:user_id_arr].split(",") rescue []
        update_status_str = SharedLocationMapping.update_location_mapping_data(location_id, user_id_arr) rescue "Sharing failed"
        Rails.logger.debug "Ending #{self}::#{__method__.to_s}"
        if update_status_str != "Sharing failed"
            if !user_id_arr.present?
                update_status_str = "Location successfully shared publicly"
            end
        end
        render :plain => update_status_str
    end
end