class SharedLocationMapping < ApplicationRecord
    belongs_to :location_register
    # belongs_to :user
    # has_many :location_registers
    # has_many :users, through: :location_registers

    # Method to insert mapping data for the given location id, and user_id
    # If user id is missing then it will entry data as publicly shared
    def self.insert_mapping_data(location_id, user_id=0)
        Rails.logger.info "Starting #{self}::#{__method__.to_s}"
        args = method(__method__).parameters.collect{|p| p[1].to_s}
        Rails.logger.info ("PARAMETERS RECEIVED --" + 
                            args.map{|a| "#{a} = #{eval a}"}.join(','))
        mapping_obj = self.new
        mapping_obj["location_register_id"] = location_id
        mapping_obj["shared_user_id"] = user_id
        mapping_obj.save
        Rails.logger.info "Ending #{self}::#{__method__.to_s}"
        return mapping_obj
    end

    # Method to delete all mapping data for location_id... take optional parameter
    # user_ids array if user_ids arr present then delete only datas associated
    # with the given user_ids otherwise delete all data for the location_id
    def self.delete_location_wise_mapping_data(location_id, user_ids=[])
        Rails.logger.info "Starting #{self}::#{__method__.to_s}"
        args = method(__method__).parameters.collect{|p| p[1].to_s}
        Rails.logger.info ("PARAMETERS RECEIVED --" + 
                            args.map{|a| "#{a} = #{eval a}"}.join(','))
        if user_ids.present?
            # Delete all records for mapping location id and also filter with given
            # shared_user_ids
            self.where("location_register_id = #{location_id} 
                        AND shared_user_id IN(#{user_ids.join(',')})").destroy_all
        else
            # Delete all records for mapping location id
            self.where("location_register_id = #{location_id}").destroy_all
        end
        Rails.logger.info "Ending #{self}::#{__method__.to_s}"
        return
    end

    # Method to fetch existing mapping data for the given location id
    def self.fetch_existing_mapping_data_with_location_id_wise(location_id)
        Rails.logger.info "Starting #{self}::#{__method__.to_s}"
        args = method(__method__).parameters.collect{|p| p[1].to_s}
        Rails.logger.info ("PARAMETERS RECEIVED --" + 
                            args.map{|a| "#{a} = #{eval a}"}.join(','))
        mapping_data_obj = self.where("location_register_id = #{location_id}") rescue []
        Rails.logger.info "Ending #{self}::#{__method__.to_s}"
        return mapping_data_obj
    end

    # Method to create record in mapping table
    def self.update_location_mapping_data(location_id, shared_users = [])
        Rails.logger.info "Starting #{self}::#{__method__.to_s}"
        args = method(__method__).parameters.collect{|p| p[1].to_s}
        Rails.logger.info ("PARAMETERS RECEIVED --" + 
                            args.map{|a| "#{a} = #{eval a}"}.join(','))
        # Check user ids are present or not... if present then create entries
        # for each user_ids in the mapping table for the corresponding location_id
        # Also compare with previously inserted mapping data in the table and delete
        # if required
        existing_shared_user_ids = fetch_existing_mapping_data_with_location_id_wise(location_id).pluck(:shared_user_id) rescue []
        if shared_users.present?
            # Check any entries needs to be delete or not
            entries_to_be_deleted_for_users = existing_shared_user_ids - shared_users
            if entries_to_be_deleted_for_users.present?
                # Call for delete entries for the user ids and corresponding location_id
                delete_location_wise_mapping_data(location_id, entries_to_be_deleted_for_users)
            end                
            
            # Now call for fresh entries
            entries_to_be_inserted = shared_users-existing_shared_user_ids
            entries_to_be_inserted.each do |user_id|
                insert_mapping_data(location_id, user_id)
            end
        else # Calling for publicly shared location
            # Check any entries needs to be delete or not
            if existing_shared_user_ids.length > 1
                # Then no need to check user id whether it is 0 on not as for each location id only one
                # record will be there for user id with 0... direct call for delete
                delete_location_wise_mapping_data(location_id)
                # Now call for entry with zero user id for public share
                insert_mapping_data(location_id, 0)
            else
                # Check whether single id is zero or not if zero then skip deletion or insert
                # Otherwise insert after deleting the record
                if !existing_shared_user_ids.include?(0)
                    delete_location_wise_mapping_data(location_id)
                    # Now call for entry with zero user id for public share
                    insert_mapping_data(location_id, 0)
                end
            end
        end

        Rails.logger.info "Ending #{self}::#{__method__.to_s}"
        return "Location shared with user(s) successfully"
    end

    
    # Method to fetch the shared location from mapping table with respect to 
    # user_id if no user id provided then it will return only publicly shared location
    # this method also receive additional argument for deciding whether reponse
    # required publicly shared locations or not, it is applicable only for valid user_id(>0)
    def self.fetch_mapped_locations_with_user(user_id = 0, include_public = true)
        Rails.logger.info "Starting #{self}::#{__method__.to_s}"
        args = method(__method__).parameters.collect{|p| p[1].to_s}
        Rails.logger.info ("PARAMETERS RECEIVED --" + 
                            args.map{|a| "#{a} = #{eval a}"}.join(','))
        filter_str = "#{user_id.to_i}" rescue "0"
        # Now check given user id is default zero or not
        # If not zero then checking with additional parameter to decide whether
        # result data includes publicly shared locations or not if true then 
        # updating filter string by concatinating zero in it as publicly shared
        # locations stored with user_id 0 in mapping table
        if user_id.to_i > 0
            if include_public
                filter_str += ",0"
            end
        end
        locations_obj = self.where("shared_user_id IN (#{filter_str})") #rescue []
        Rails.logger.info "Ending #{self}::#{__method__.to_s}"
        return locations_obj
    end

end
