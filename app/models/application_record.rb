class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.set_connection
    if RequestStore.store[:company_type].present?
      Rails.cache.clear
      establish_connection "#{Rails.env}_#{RequestStore.store[:company_type]}".to_sym
    else
      establish_connection "#{Rails.env}".to_sym
    end
  end

  # include PublicActivity::Model
  # tracked owner: Proc.new{ |controller, model| controller.current_user },
  #         parameters: :previous_changes
end
