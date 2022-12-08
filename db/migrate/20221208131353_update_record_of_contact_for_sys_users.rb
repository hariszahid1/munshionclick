class UpdateRecordOfContactForSysUsers < ActiveRecord::Migration[6.1]
  def change
    Contact.all.each do |c|
      if c.sys_user_id.present?
        c.update(contactable_id: c.sys_user_id, contactable_type: "SysUser")
      end
    end
  end
end
