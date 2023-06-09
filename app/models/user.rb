class User < ApplicationRecord

  establish_connection "#{Rails.env}".to_sym
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
	has_many :user_permissions
  has_one :user_ability, dependent: :destroy
  has_many :admins, -> (object) {
    where("roles_mask = ?", mask_no("admin"))
  }, class_name: :User, foreign_key: :created_by_id

	accepts_nested_attributes_for :user_permissions

  after_create :create_user_ability
  after_create :create_user_permission
  # has_many_attached :backup_files
  # validates :name, presence: true, uniqueness: { case_sensitive: false }
  has_many :accounts
  include RoleModel
  # Declare the valid roles. Do not change the order if you add more roles later, always append them
  # at the end! To remove roles, don't forget to re-assign all roles as they're position dependent.
  roles :developer, :super_admin, :admin, :staff, :salesman, :editor, :visitor
  enum user_roles: { admin: 4, staff: 8, salesman: 16, editor: 32, visitor: 64 }
  has_paper_trail ignore: [:updated_at]
  has_many :follow_ups, foreign_key: 'created_by', primary_key: 'id'
  has_many :notes, foreign_key: 'created_by', primary_key: 'id'

  def self.mask_no(rol)
    User.mask_for rol
  end

  def developer?
    has_role?(:developer)
  end

  def editor?
    has_role?(:editor)
  end

  def visitor?
    has_role?(:visitor)
  end

  def staff?
    has_role?(:staff)
  end

  def salesman?
    has_role?(:salesman)
  end

  def admin?
    has_role?(:admin)
  end

  def super_admin?
    has_role?(:super_admin)
  end

  def self.find_for_database_authentication(conditions={})
    find_by(user_name: conditions[:email]) || find_by(email: conditions[:email])
  end

  def create_user_ability
    unless user_ability.present?
      userAbility = build_user_ability
      userAbility.save
    end
  end

	def create_user_permission
    pos_all_modules = ['dashboard', 'helps', 'home', 'logs', 'reports', 'accounts', 'active_storage_attachments',
                       'active_storage_blobs', 'active_storage_variant_records', 'activities', 'ar_internal_metadata',
                       'attendances', 'cities', 'compaign_entries', 'compaigns', 'contacts', 'countries', 'crontests',
                       'daily_attendances', 'daily_books', 'daily_sales', 'db_backup_files', 'departments',
                       'expense_entries', 'expense_entry_vouchers', 'expense_types', 'expense_vouchers', 'expenses',
                       'follow_ups', 'gates', 'import_mappings', 'investments', 'item_types', 'items', 'ledger_books',
                       'links', 'loans', 'map_columns', 'materials', 'notes', 'order_items', 'orders', 'payments',
                       'pdf_template_elements', 'pdf_templates', 'pos_settings', 'product_categories',
                       'product_stock_exchanges', 'product_stocks', 'product_sub_categories', 'product_warranties',
                       'production_block_types', 'production_blocks', 'production_cycles', 'productions', 'products',
                       'profit_reports', 'property_installments', 'property_plans', 'purchase_sale_details',
                       'purchase_sale_items', 'raw_products', 'remarks', 'salaries', 'salary_detail_product_quantities',
                       'salary_details', 'schema_migrations', 'sms_logs', 'staff_deals', 'staff_ledger_books',
                       'staff_raw_products', 'staffs', 'sticky_notes', 'sys_users', 'user_abilities', 'user_groups',
                       'user_permissions', 'user_types', 'users', 'versions', 'warranties', 'sms', 'sys_users/customer',
                       'sys_users/supplier', 'sys_users/own', 'crms', 'mobile_shop_product_purchases', 'deals']

    pos_all_modules.each do |item|
      UserPermission.create(module: item, can_create: true,can_read: true, can_update: true, can_delete: true, user_id: id, is_hidden: true) if super_admin?
      UserPermission.create(module: item, can_create: true,can_read: true, can_update: true, can_delete: false, user_id: id, is_hidden: true) if admin?
      UserPermission.create(module: item, can_create: true,can_read: true, can_update: false, can_delete: false, user_id: id, is_hidden: true) if staff?
      UserPermission.create(module: item, can_create: true,can_read: true, can_update: false, can_delete: false, user_id: id, is_hidden: true) if salesman?
      UserPermission.create(module: item, can_create: true,can_read: true, can_update: false, can_delete: false, user_id: id, is_hidden: true) if editor?
      UserPermission.create(module: item, can_create: false,can_read: true, can_update: false, can_delete: false, user_id: id, is_hidden: true) if visitor?
    end
  end

  def allowed_valid_roles
    if super_admin?
      :admin
    elsif admin?
      :staff
    end
  end

  def allowed_to_view_roles_mask_for
    mask_for = []
    if super_admin?
      User.valid_roles[1..8].each do |msk|
        mask_for.push(User.mask_for msk)
      end
    elsif admin?
    end
    mask_for
  end

  def allowed_valid_roles_mask_for
    mask_for = []
    if super_admin?
      User.valid_roles[2..2].each do |msk|
        mask_for.push(User.mask_for msk)
      end
    elsif admin?
      User.valid_roles[0..1].each do |msk|
        mask_for.push(User.mask_for msk)
      end
    end
    mask_for
  end

  def created_by_ids_list_to_view
    ids_list = []
    if super_admin?
      ids_list.push(self.id)
    elsif admin?
      staff_list = User.where(created_by_id: self.id).uniq
      ids_list = staff_list.pluck(:id)
      ids_list.push(self.id)
    end
    ids_list
  end

  def admin_staffs_ids
    ids_list = []
    if super_admin?
      ids_list.push(self.id)
    elsif admin?
      staff_list = User.where(created_by_id: self.id).uniq
      ids_list = staff_list.pluck(:id)
      ids_list.push(self.id)
    end
    ids_list
  end

  def superAdmin
    if super_admin?
      self
    elsif admin?
      User.find_by(id: created_by_id)
    elsif staff?
      admin_super = User.find_by(id: created_by_id)
      unless admin_super.super_admin?
        admin_super = User.find_by(id: admin_super.created_by_id)
      end
      admin_super
    elsif salesman? or visitor? or editor?
      admin_super = User.find_by(id: created_by_id)
      unless admin_super.super_admin?
        admin_super = User.find_by(id: admin_super.created_by_id)
      end
      admin_super
    else
      self
    end
  end

  def user_account
    self.accounts.last.id if self.accounts.present?
  end
end
