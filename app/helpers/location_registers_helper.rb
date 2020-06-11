module LocationRegistersHelper
    def self.get_default_coordinates
        Rails.logger.info "Starting #{self}::#{__method__.to_s}"
        coordinates = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]["default_coordinates"] rescue []
        # Extra checking if any problem occurred during fetch data from config file or no data set in config
        if !coordinates.present?
            coordinates = [88.3627138688202,22.5827570785926]
        end
        return coordinates
    end
end
