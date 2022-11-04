class AccountsController < ApplicationController
	before_action :check_access
  before_action :set_account, only: [:show, :edit, :update, :destroy]

  # GET /accounts
  # GET /accounts.json
  def index
    @pos_setting=PosSetting.first
    @q = Account.ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = 'id asc' if @q.sorts.empty?
    end
    if params[:q].present?
      @title = params[:q][:title_or_bank_name_cont]
      @comment = params[:q][:bank_name]
    end
    @accounts = @q.result(distinct: true).page(params[:page])
    @account = @q.result
    @account_total=@account.pluck('SUM(amount)')

    if params[:submit_pdf_staff_with].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @accounts=@q.result(distinct: true)
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: 'index_staff_wise',
          layout: 'pdf.html',
          page_size: 'A4',
          margin_top: '0',
          margin_right: '0',
          margin_bottom: '0',
          margin_left: '0',
          encoding: "UTF-8",
          footer:  {             # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
          right: '[page] of [topage]'},
          show_as_html: false
        end
      end
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
      params.require(:account).permit(:title, :bank_name, :iban_number, :amount, :user_id, :profile_image)
    end
end
