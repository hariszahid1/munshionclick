class UsersController < ApplicationController
  load_and_authorize_resource
  # skip_authorize_resource :only => :new
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    ransack_search
    @users = @q.result(distinct: true).page(params[:page])
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new(created_by_id: current_user.id)
  end

  # GET /users/1/edit
  def edit
  end

  def create_user
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        save_user_ability
        format.html { redirect_to @user, notice: "#{current_user.allowed_valid_roles.to_s.titleize} was successfully created." }
        format.json { render :show, status: :created, location: @user }
      else
        set_part_list
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if params[:user][:password].blank?
      params[:user].delete :password
    end
    respond_to do |format|
      if @user.update(user_params)
        save_user_ability
        format.html { redirect_to dashboard_path, notice: "#{current_user.allowed_valid_roles.to_s.titleize} was successfully updated." }
        format.json { render :show, status: :ok, location: @user }
      else
        set_part_list
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: "#{current_user.allowed_valid_roles.to_s.titleize} was successfully destroyed." }
      format.json { head :no_content }
      format.js   { render :layout => false }
    end
  end

  private

    def ransack_search
      created_by_ids = current_user.created_by_ids_list_to_view
      roles_mask = current_user.allowed_to_view_roles_mask_for
      @q = User.where(roles_mask: roles_mask).where('company_type=? or created_by_id=?',current_user.company_type,created_by_ids).ransack(params[:q])
      if @q.result.count > 0
        @q.sorts = 'name asc' if @q.sorts.empty?
      end
    end

    def save_user_ability
      userAbility = @user.user_ability.present? ? @user.user_ability : @user.build_user_ability
      if params[:user][:user_ability_roles].present?
        params[:user][:user_ability_roles].each do |user_ability|
          userAbility.roles << user_ability
        end
      end
      userAbility.save!
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :user_name, :email, :father_name, :city, :phone, :fax, :address, :roles, :password, :confirm_password, :user_ability_roles, :created_by_id, :email_to,:email_cc,:email_bcc,:roles_mask)
    end
end
