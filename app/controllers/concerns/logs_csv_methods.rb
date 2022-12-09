# frozen_string_literal: true

# CSV Methods
module LogsCsvMethods
  extend ActiveSupport::Concern

	def logs_csv
		CSV.generate do |csv|
      csv.add_row ["Date: #{@date = Date.today}"]
      csv.add_row ["Time: #{@time = Time.zone.now}"]
      csv.add_row ['-----------------------------------']	
      csv.add_row ["Activity Log Details"]
      csv.add_row ["Report By: #{current_user.name}"]
      csv.add_row ['-----------------------------------']	
      csv.add_row ['Logs', 'Who Done it','Date','Action']
      csv.add_row ['-----------------------------------']	

      @logs.each do |log|

        csv.add_row [
          log.item_type,
          log&.whodunnit,
          log.created_at.present? ? log.created_at.strftime("%d%b%y at %I:%M %p") : '',
          log.event
        ]

        if log&.changeset.present?
          if log&.changeset[:balance].present?
            log&.changeset[:balance].first
            log&.changeset[:balance].last
          end
        end
      end
      
      csv.add_row ["Total: #{@logs.count}"]
		end
	end

end

