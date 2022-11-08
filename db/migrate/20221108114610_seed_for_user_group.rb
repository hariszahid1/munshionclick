class SeedForUserGroup < ActiveRecord::Migration[6.1]
  def change
    user_group = %w[Customer Supplier Both Salesman Own Investor Investment
      Worker Other LandLord MD-Investment
                  ]
    index = 0
    user_group.each do |u|
      UserGroup.create(id: index, title: u)
      index += 1
    end
  end
end
