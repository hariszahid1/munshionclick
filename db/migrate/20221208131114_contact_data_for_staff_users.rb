class ContactDataForStaffUsers < ActiveRecord::Migration[6.1]
  def change
    Staff.all.each do |s|
      Contact.create(contactable_id: s.id, contactable_type: 'Staff', address: s.address,
        permanent_address: s.address, home: s.phone, city_id: City.first.id, country_id: Country.first.id)
    end
  end
end
