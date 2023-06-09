class UsersController < ApplicationController
  load_and_authorize_resource
  # skip_authorize_resource :only => :new
  before_action :set_user, only: %i[show edit update destroy]
  include PdfCsvGeneralMethod
  include UsersHelper

  # GET /users
  # GET /users.json
  def index
    ransack_search
    @q.sorts = 'id asc' if @q.sorts.empty? && @q.result.count.positive?
    @options_for_select = User.all
    @custom_pagination = params[:limit].present? ? params[:limit] : 25
    @custom_pagination = @pos_setting.custom_pagination['users'] if @pos_setting&.custom_pagination.present? && @pos_setting&.custom_pagination['users'].present?
    @users = @q.result.page(params[:page]).per(@custom_pagination)
    download_users_csv_file if params[:csv].present?
    download_users_pdf_file if params[:pdf].present?
    send_email_file if params[:email].present?
    export_file if params[:export_data].present?
  end

  # GET /users/1
  # GET /users/1.json
  def show
    respond_to do |format|
      format.js
      format.html
    end
  end

  # GET /users/new
  def new
    @user = User.new(created_by_id: current_user.id)
  end

  # GET /users/1/edit
  def edit
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create_user
    user_params[:extra_settings] = eval(user_params[:extra_settings])
    @user = User.new(user_params)
    respond_to do |format|
      if @user.save
        save_user_ability
        format.html do
          redirect_to @user, notice: "#{current_user.allowed_valid_roles.to_s.titleize} was successfully created."
        end
        format.json { render :show, status: :created, location: @user }
      else
        set_part_list
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    params[:user].delete :password if params[:user][:password].blank?
    # User.find(params[:id]).update(permission_updated:false)
    respond_to do |format|
      if @user.update(user_params)
        @user.update(extra_settings: eval(user_params[:extra_settings]))
        save_user_ability
        format.html do
          redirect_to users_path,
                      notice: "#{current_user.allowed_valid_roles.to_s.titleize} was successfully updated."
        end
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
      format.html do
        redirect_to users_url, notice: "#{current_user.allowed_valid_roles.to_s.titleize} was successfully destroyed."
      end
      format.json { head :no_content }
      format.js   { render layout: false }
    end
  end

  private

  def ransack_search
    created_by_ids = current_user.created_by_ids_list_to_view
    roles_mask = current_user.allowed_to_view_roles_mask_for
    @q = User.where(roles_mask: roles_mask).where('company_type=? or created_by_id=?', current_user.company_type,
                                                  created_by_ids).ransack(params[:q])
    @q.sorts = 'name asc' if @q.result.count > 0 && @q.sorts.empty?
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
    params.require(:user).permit(:name, :user_name, :email, :father_name, :city, :phone, :fax, :address, :roles,
                                 :password, :confirm_password, :user_ability_roles, :created_by_id, :email_to, :email_cc, :email_bcc, :roles_mask)
  end

  def download_users_csv_file
    @users = @q.result
    header_for_csv = %w[Id Role Name User_Name System_Email Email_on Father_Name Phone]
    data_for_csv = get_data_for_users_csv
    generate_csv(data_for_csv, header_for_csv,
                 "Admins-Total-#{@users.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}")
  end

  def download_users_pdf_file
    @users = @q.result
    generate_pdf(@users.as_json, "Admins-Total-#{@users.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}",
                 'pdf.html', 'A4', false, 'users/index.pdf.erb')
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(
      :name, :user_name, :email, :father_name, :city, :phone, :fax,
      :address, :roles, :password, :confirm_password, :user_ability_roles,
      :created_by_id, :email_to, :email_cc, :email_bcc, :roles_mask, :permission_updated, :extra_settings,
      user_permissions_attributes: %i[id can_accessed can_create can_read can_update can_delete can_download_pdf
                                      can_download_csv can_send_email can_import_export is_hidden]
    )
  end

  def send_email_file
    EmailJob.perform_later(@q.result.as_json, 'users/index.pdf.erb', params[:email_value],
                           params[:email_choice], params[:subject], params[:body],
                           current_user, "Admins-Total-#{@q.result.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}")
    flash[:notice] = if params[:email_value].present?
                       "Email has been sent to #{params[:email_value]}"
                     else
                       "Email has been sent to #{current_user.email}"
                     end
    redirect_to users_path
  end

  def export_file
    export_data('User')
  end
end
