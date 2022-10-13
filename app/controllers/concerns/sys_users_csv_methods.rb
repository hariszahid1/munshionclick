# frozen_string_literal: true

# CSV Methods
module SysUsersCsvMethods
  extend ActiveSupport::Concern

	def user_csv
		CSV.generate do |csv|
			csv.add_row ['Code', 'Name','User group','Status','Ocupation','Opening blance','balance','jama/benam','address']
			
			@sys_users.each do |sys_user|
				temp=''
				if (sys_user.balance.to_f > 0 )
					temp="Jama"
				elsif (sys_user.balance.to_f < 0 )
					temp="Benam"
				else
					temp=''
				end
				csv.add_row ["#{sys_user.code}","#{sys_user.name}","#{sys_user.user_group}","#{sys_user.status}","#{sys_user.occupation}","#{sys_user.opening_balance.to_f.round(2)}","#{sys_user.balance.to_f.round(2)}","#{temp}","#{sys_user.contact.city.title}"]
			end
		end
	end

	def payable_csv
		@sys_user_balance=0
		CSV.generate do |csv|
			csv.add_row ['Code', 'Name','User type','User group','Balance','Last Payment']
			@count=0

			 @sys_users.each do |sys_user| 
				 if  (sys_user.balance > 0) 
					@count=@count+1
					@sys_user_balance += sys_user.balance.abs
					date = (sys_user.ledger_books.present? ? sys_user.ledger_books.last.created_at : sys_user.created_at)
					csv.add_row [ 
						sys_user.code,
						sys_user.name,
						sys_user.user_type.title,
						sys_user.user_group,
						sys_user.balance.abs,
						date.strftime("%d%b%y at %I:%M%p")
					]
				  end 
			  end 
				csv.add_row [ 
					"Total",
					@count,
					"",
					"",
					@sys_user_balance,
					""
				]	
		end
	end

	def receiveable_csv
		@sys_user_balance=0
		@time = Time.zone.now
		@time = DateTime.now
		@date = Date.today
		@time = Time.zone.now
		CSV.generate do |csv|
			csv.add_row ['-----------------------']
			csv.add_row ["Receiveable Details => #{@time.strftime("%d")} / #{@time.strftime("%b")} / #{@time.strftime("%y")}"]
			csv.add_row ['-----------------------']

			csv.add_row ['Code', 'Name','User type','User group','Balance','Last Payment']
			@count=0
			 @sys_users.each do |sys_user| 
				 if  (sys_user.balance < 0) 
					date = (sys_user.ledger_books.present? ? sys_user.ledger_books.last.created_at : sys_user.created_at)
					@count=@count+1
					@sys_user_balance += sys_user.balance.abs
					date = (sys_user.ledger_books.present? ? sys_user.ledger_books.last.created_at : sys_user.created_at)
					csv.add_row [ 
						sys_user.code,
						sys_user.name,
						sys_user.user_type.title,
						sys_user.user_group,
						sys_user.balance.abs,
						date.strftime("%d%b%y at %I:%M%p")
					]
				  end 
			  end 
				csv.add_row [ 
					"Total",
					@count,
					"",
					"",
					@sys_user_balance,
					""
				]	
		end
	end

end
