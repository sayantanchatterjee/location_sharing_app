class User < ApplicationRecord
  extend Devise::Models
  has_many :location_registers
  # has_many :shared_location_mappings, :foreign_key => :shared_user_id
  # Include default devise modules. Others available are:
  # :confirmable, :lockableand :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, 
         :timeoutable, :trackable
  
  attr_writer :login

  validates :username, :presence => true, :uniqueness => { :case_sensitive => false } 

  def login
		@login || self.username || self.email
	end
  
  # Method for handling both email and username as login id
	def self.find_for_database_authentication(warden_conditions)
		conditions = warden_conditions.dup
		if username = conditions.delete(:login)
			where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { :value => username }]).first
		elsif conditions.has_key?(:username) || conditions.has_key?(:email)
			where(conditions.to_h).first
		end
  end

  # fetch users list other than current user and generate table data
  def self.fetch_other_users(current_user_id)
    Rails.logger.info "Starting #{self}::#{__method__.to_s}"
    args = method(__method__).parameters.collect{|p| p[1].to_s}
    Rails.logger.info ("PARAMETERS RECEIVED --" + 
                        args.map{|a| "#{a} = #{eval a}"}.join(','))
    users_list = self.where("id != #{current_user_id}") rescue []
    # Updating hash for details button on clicking which, will open
    # a page for the selected user and list all of his/her publicly
    # shared location
    response_hash = []
    users_list.each do |user|
      inner_hash = user.as_json
      inner_hash["details_button"] = "<input class='btn-cust' type='button' value='Show' onclick='show_user_details(\"#{user.username.to_s}\")' >"
      response_hash << inner_hash
    end
    Rails.logger.info "Ending #{self}::#{__method__.to_s}"
    return response_hash
  end
end
