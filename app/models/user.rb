class User < ApplicationRecord

  establish_connection "#{Rails.env}".to_sym
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :user_ability, dependent: :destroy
  has_many :admins, -> (object) {
    where("roles_mask = ?", mask_no("admin"))
  }, class_name: :User, foreign_key: :created_by_id

  after_create :create_user_ability
  # has_many_attached :backup_files
  has_many :accounts
  include RoleModel
  # Declare the valid roles. Do not change the order if you add more roles later, always append them
  # at the end! To remove roles, don't forget to re-assign all roles as they're position dependent.
  roles :developer, :super_admin, :admin, :staff, :salesman, :editor, :visitor
  enum user_roles: { admin: 4, staff: 8, salesman: 16, editor: 32, visitor: 64 }

  has_paper_trail ignore: [:updated_at]

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