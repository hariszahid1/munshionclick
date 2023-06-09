class AccountsController < ApplicationController
	before_action :check_access
  before_action :set_account, only: [:show, :edit, :update, :destroy]
  include AccountsHelper
  include PdfCsvGeneralMethod

  # GET /accounts
  # GET /accounts.json
  def index
    @account_ids = Account.where(id: current_user&.extra_settings.try(:[], 'account_ids'))
    @pos_setting=PosSetting.first
    if @account_ids.present?
      @q = Account.where(id: @account_ids).order('id asc').ransack(params[:q])
    else
      @q = Account.order('id asc').ransack(params[:q])
    end
    @accounts = @q.result(distinct: true).page(params[:page])
    @account = @q.result
    @account_total=@account.pluck('SUM(amount)')

    if params[:csv].present?
      request.format = 'csv'
      download_accounts_csv_file
    end
    download_accounts_pdf_file if params[:pdf_asc].present? || params[:pdf_desc].present?
    send_email_file if params[:email].present?
    if params[:export_data].present?
      request.format = 'csv'
      export_file
    end

    @account_title = []
    @account_amount = []
    @accounts.each do |account|
      @account_title.push(account.title.split(' ').join(''))
      @account_amount.push(account.amount.to_f.round(2))
    end

    respond_to do |format|
      format.pdf
      format.csv
      format.js
      format.html
    end
  end

  # GET /accounts/1
  # GET /accounts/1.json
  def show
    created_by_ids = current_user.created_by_ids_list_to_view
    roles_mask = current_user.allowed_to_view_roles_mask_for
    @users = User.where(roles_mask: roles_mask).where('company_type=? or created_by_id=?',current_user.company_type,created_by_ids)
  end

  # GET /accounts/new
  def new
    @account = Account.new
    created_by_ids = current_user.created_by_ids_list_to_view
    roles_mask = current_user.allowed_to_view_roles_mask_for
    @users = User.where(roles_mask: roles_mask).where('company_type=? or created_by_id=?',current_user.company_type,created_by_ids)

  end

  # GET /accounts/1/edit
  def edit
    created_by_ids = current_user.created_by_ids_list_to_view
    roles_mask = current_user.allowed_to_view_roles_mask_for
    @users = User.where(roles_mask: roles_mask).where('company_type=? or created_by_id=?',current_user.company_type,created_by_ids)
  end

  # POST /accounts
  # POST /accounts.json
  def create
    @account = Account.new(account_params)

    respond_to do |format|
      if @account.save
        format.js
        format.html { redirect_to accounts_path, notice: 'Account was successfully created.' }
        format.json { render :show, status: :created, location: @account }
      else
        format.html { render :new }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /accounts/1
  # PATCH/PUT /accounts/1.json
  def update
    respond_to do |format|
      if @account.update(account_params)
        format.html { redirect_to accounts_path, notice: 'Account was successfully updated.' }
        format.json { render :show, status: :ok, location: @account }
      else
        format.html { render :edit }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @account.destroy
    respond_to do |format|
      format.html { redirect_to accounts_url, notice: 'Account was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }
    end
  end

  def account_balance
    account = Account.find(params[:account_id])
    respond_to do |format|
      format.json { render json: {status: 'success', balance: account.amount}, status: :ok}
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_account
    @account = Account.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def account_params
    params.require(:account).permit(:title, :bank_name, :iban_number, :amount, :user_id, :default_account, :profile_image)
  end

  def download_accounts_csv_file
    @accounts = @q.result
      header_for_csv = %w[id title bank balance jama_benam]
      data_for_csv = get_data_for_accounts_csv
    generate_csv(data_for_csv, header_for_csv,
                 "Accounts-Total-#{@accounts.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}")
  end

  def download_accounts_pdf_file
    sort_data_according
    generate_pdf(@sorted_data.as_json, "Accounts-Total-#{@sorted_data.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}",
                 'pdf.html', 'A4', false, 'accounts/index.pdf.erb')
  end

  def send_email_file
    sort_data_according
    EmailJob.perform_later(@sorted_data.as_json, 'accounts/index.pdf.erb', params[:email_value],
                           params[:email_choice], params[:subject], params[:body],
                           current_user, "Accounts-Total-#{@sorted_data.count}-#{DateTime.now.strftime('%d-%m-%Y-%H-%M')}")
    flash[:notice] = if params[:email_value].present?
                       "Email has been sent to #{params[:email_value]}"
                     else
                       "Email has been sent to #{current_user.email}"
                     end
    redirect_to accounts_path
  end

  def sort_data_according
    @sorted_data = []
      sorting_type = 'created_at asc'
      sorting_type = 'created_at desc' if params[:pdf_desc].present?

      @q.result.reorder(sorting_type).each do |d|
        @sorted_data << {
                          id: d.id,
                          title: d.title,
                          bank: d.bank_name,
                          balance: d.amount.to_f.round(2),
                          jama_benam: d.amount.to_i.zero? ? 'Nill' : d.amount.to_f.negative? ? 'Jama' : 'Benam',
                          total: @account_total.first.to_f.round(2)
                        }
      end
  end

  def export_file
    export_data('Account')
  end

end
