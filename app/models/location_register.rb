class LocationRegister < ApplicationRecord
    has_many :shared_location_mappings, dependent: :destroy
    belongs_to :user
    # belongs_to :shared_location_mappings

    # Method to insert location data for the current user
    def self.insert_location_data(latitude, longitude, user_id)
        Rails.logger.info "Starting #{self}::#{__method__.to_s}"
        args = method(__method__).parameters.collect{|p| p[1].to_s}
        Rails.logger.info ("PARAMETERS RECEIVED --" + 
                            args.map{|a| "#{a} = #{eval a}"}.join(','))
        location_reg_obj = self.new
        location_reg_obj["latitude"] = latitude
        location_reg_obj["longitude"] = longitude
        location_reg_obj["user_id"] = user_id
        location_reg_obj.save
        location_id = location_reg_obj.id rescue 0
        Rails.logger.info "Ending #{self}::#{__method__.to_s}"
        return location_id
    end

    # Method to fetch the shared location with respect to user_id
    # if no user id provided then it will return on publicly shared location
    # Take user_id as parameter which is optional
    def self.fetch_shared_locations_by_user(user_id)
        Rails.logger.info "Starting #{self}::#{__method__.to_s}"
        args = method(__method__).parameters.collect{|p| p[1].to_s}
        Rails.logger.info "PARAMETERS RECEIVED --" + args.map{|a| "#{a} = #{eval a}"}.join(',')
        # Fetch locations which are shared by self user
        locations_shared_by_self_obj = self.fetch_self_shared_location(user_id) rescue []
        # Locations shared by other users with self users
        locations_shared_by_other_obj = self.fetch_locations_shared_by_others_for_user(user_id) rescue []

        Rails.logger.info "Ending #{self}::#{__method__.to_s}"
        return locations_shared_by_self_obj, locations_shared_by_other_obj
    end

    # Method to fecth self shared locations only which can be shared... also generate the hash with additional keys
    def self.fetch_self_shared_location(user_id, is_only_publicly_shared_locations = false)
        Rails.logger.info "Starting #{self}::#{__method__.to_s}"
        args = method(__method__).parameters.collect{|p| p[1].to_s}
        Rails.logger.info "PARAMETERS RECEIVED --" + args.map{|a| "#{a} = #{eval a}"}.join(',')
        only_public_filter = ""
        # If only publicly shared location required then update the query
        if is_only_publicly_shared_locations
            only_public_filter = " AND slm.shared_user_id = 0"
        end
        fetch_query_str = ("SELECT DISTINCT lr.id, lr.*, u.username FROM 
        location_registers lr LEFT JOIN users u ON u.id = lr.user_id 
        LEFT JOIN shared_location_mappings slm on lr.id = slm.location_register_id  
        WHERE lr.user_id = #{user_id.to_s} #{only_public_filter}")
        
        fetch_obj = self.find_by_sql(fetch_query_str) rescue []
        response_hash_obj = []
        if fetch_obj.present?
            # Now iterate through each object and generate response hash
            fetch_obj.each do |row|
                inner_hash = row.as_json
                inner_hash["show_on_map"] = "<input class='btn-cust' type='button' value='Show' onclick='show_location("+row.longitude.to_s+","+row.latitude.to_s+")' >"
                inner_hash["share_location"] = "<input class='btn-cust' type='button' value='Share' onclick='openLocationShareModal("+row.id.to_s+")' >"
                inner_hash["destroy_location"] = "<input class='btn-danger' type='button' value='Delete' onclick='deleteLocationData("+row.id.to_s+")' >"
                
                response_hash_obj << inner_hash
            end
        end
        Rails.logger.info "Ending #{self}::#{__method__.to_s}"
        return response_hash_obj
    end

    # Method to fecth shared locations by other with the user and public... 
    # also generate the hash with additional keys for show button only 
    # here sharing is not allowed
    def self.fetch_locations_shared_by_others_for_user(user_id)
        Rails.logger.info "Starting #{self}::#{__method__.to_s}"
        args = method(__method__).parameters.collect{|p| p[1].to_s}
        Rails.logger.info "PARAMETERS RECEIVED --" + args.map{|a| "#{a} = #{eval a}"}.join(',')
        fetch_query_str = ("SELECT lr.*, u.username FROM location_registers lr 
        LEFT JOIN shared_location_mappings slm ON slm.location_register_id = lr.id 
        LEFT JOIN users u ON u.id = lr.user_id WHERE slm.shared_user_id = #{user_id.to_s}")
        fetch_obj = self.find_by_sql(fetch_query_str)
        response_hash_obj = []
        if fetch_obj.present?
            # Now iterate through each object and generate response hash
            fetch_obj.each do |row|
                inner_hash = row.as_json
                inner_hash["show_on_map"] = "<input class='btn-cust' type='button' value='Show' onclick='show_location("+row.longitude.to_s+","+row.latitude.to_s+")' >"                
                response_hash_obj << inner_hash
            end
        end
        Rails.logger.info "Ending #{self}::#{__method__.to_s}"
        return response_hash_obj
    end

end
