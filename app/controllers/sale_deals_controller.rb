class SaleDealsController < ApplicationController
  include PdfCsvGeneralMethod
  include SaleDealsHelper

  before_action :set_sale_deal, only: %i[show edit update destroy approve_requested_deal]
  before_action :set_data, only: %i[new edit create update show index]
  skip_before_action :authenticate_user!, only: [:show]

  # GET /sale_deals
  # GET /sale_deals.json
  def index
    @q = PurchaseSaleDetail.includes(:sys_user, :purchase_sale_items).order('id desc').where(
      transaction_type: %w[NewSaleDeal ReSaleDeal]).ransack(params[:q])
    download_sale_deals_pdf_file if params[:pdf].present?
    download_sale_deals_csv_file if params[:csv].present?
    @sale_deals = @q.result.page(params[:page])
  end

  # GET /sale_deals/1
  # GET /sale_deals/1.json
  def show
    return show_sale_pdf if params[:pdf].present?
  end

  # GET /sale_deals/new
  def new
    @sale_deal = PurchaseSaleDetail.new
    @sale_deal.purchase_sale_items.build
    @sale_deal.follow_ups.build
  end

  # GET /sale_deals/1/edit
  def edit; end

  # POST /sale_deals
  # POST /sale_deals.json
  def create
    @sale_deal = PurchaseSaleDetail.new(sale_deal_params)
    create_sys_user if params[:purchase_sale_detail][:sys_user_id].blank? &&
                       params[:purchase_sale_detail][:sys_users].present?

    respond_to do |format|
      if @sale_deal.save
        modify_salary_details if @sale_deal.staff_id.present?
        @ledger_book = LedgerBook.new(sys_user_id: @sale_deal&.sys_user.id, debit: @sale_deal&.total_bill.to_f, credit: @sale_deal&.amount.to_f,
                                      balance: (@sale_deal&.sys_user&.balance.to_f - @sale_deal&.remaining_balance.to_f),
                                      comment: 'Voucher #' + @sale_deal&.id.to_s,
                                      purchase_sale_detail_id: @sale_deal.id, account_id: @sale_deal&.account_id)
        @ledger_book.save!
        type = params[:purchase_sale_detail]['transaction_type'] == 'ReSaleDeal' ? 8 : 9
        format.js
        format.html { redirect_to sale_deals_path('q[transaction_type_eq]': type), notice: 'Please Take Approval from admin.' }
        format.json { render :show, status: :created, location: @sale_deal }
      else
        format.html { render :new }
        format.json { render json: @sale_deal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sale_deals/1
  # PATCH/PUT /sale_deals/1.json
  def update
    return approve_requested_deal if params[:approve].present?

    respond_to do |format|
      @before_update_carriage_loading = @sale_deal.carriage + @sale_deal.loading
      if @sale_deal.update(sale_deal_params)
        type = params[:purchase_sale_detail]['transaction_type'] == 'ReSaleDeal' ? 8 : 9
        modify_update_salary_details if @sale_deal.staff_id.present?
        format.html { redirect_to sale_deals_path('q[transaction_type_eq]': type), notice: 'Sale Deal was successfully updated.' }
        format.json { render :show, status: :ok, location: @sale_deal }
      else
        format.html { render :edit }
        format.json { render json: @sale_deal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sale_deals/1
  # DELETE /sale_deals/1.json
  def destroy
    @sale_deal.destroy
    respond_to do |format|
      format.html { redirect_to sale_deals_url, notice: 'Sale Deal was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render layout: false }
    end
  end

  def requested
    @requested = PurchaseSaleDetail.includes(:sys_user, :purchase_sale_items).where(transaction_type:
      %w[ReSaleDeal NewSaleDeal], status: 'UnClear')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_sale_deal
    @sale_deal = PurchaseSaleDetail.includes(:sys_user, :purchase_sale_items).find(params[:id])
  end

  def create_sys_user
    code = 'AGC-' + '%.4i' % (SysUser.maximum(:id).present? ? SysUser.maximum(:id).next : 1)
    user = params[:purchase_sale_detail][:sys_users]
    user_id = SysUser.create(name: user[:name], code: code, user_type_id: UserType.first.id, ntn: user[:ntn],
                             occupation: user[:occupation], cms_data: user[:cms_data])
    @sale_deal[:sys_user_id] = user_id.id
  end

  def set_data
    @project_name = @pos_setting.extra_settings.present? ? PosSetting.last.extra_settings['project_name']&.map(&:downcase) : []
    @category = @pos_setting.extra_settings.present? ? @pos_setting.extra_settings['category']&.map(&:downcase) : []
    @staffs = Staff.all
    @sys_users = SysUser.all.where(for_crms: [false, nil])
    @accounts = Account.all
    @products = Product.all
    created_by_ids = current_user.created_by_ids_list_to_view
    @all_agents = User.where('company_type=? or created_by_id=?', current_user.company_type, created_by_ids).pluck(:name,
      :id)
    @payment_status = @pos_setting&.extra_settings.present? ? @pos_setting.extra_settings['payment_status'] : []
    @transaction_type = @pos_setting.extra_settings.present? ? @pos_setting.extra_settings['transaction_type'] : []
    @deal = @pos_setting.extra_settings.present? ? @pos_setting.extra_settings['deal'] : []
    roles_mask = current_user&.allowed_to_view_roles_mask_for
    @users = User.where(roles_mask: roles_mask).where('company_type=? or created_by_id=?', current_user&.company_type,
                                                      created_by_ids)
    @deal_count = PurchaseSaleDetail.joins(:purchase_sale_items).where(transaction_type: %w[NewSaleDeal ReSaleDeal]).group('purchase_sale_items.size_4').count
    @payment_status_count = PurchaseSaleDetail.joins(:purchase_sale_items).where(transaction_type: %w[NewSaleDeal ReSaleDeal]).group('purchase_sale_items.size_7').count

  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def sale_deal_params
    params.require(:purchase_sale_detail).permit(:sys_user_id, :transaction_type, :total_bill, :amount, :discount_price,
                                                  :status, :comment, :voucher_id, :created_at, :account_id, :carriage,
                                                  :loading, :order_id, :created_at, :staff_id, :bill_no, :user_name,
                                                  :destination, :l_c, :g_d, :g_d_type, :g_d_date, :quantity, :dispatched_to,
                                                  :despatch_date, :job_no, :reference_no, :company_name, :with_gst, :remaining_balance,
                                                  purchase_sale_items_attributes: %i[id purchase_sale_detail_id item_id
                                                                                    product_id quantity cost_price sale_pricestatuscomment
                                                                                    total_cost_price total_sale_price transaction_type
                                                                                    size_1 size_2 size_3 size_4 size_5 size_6 size_7 size_8
                                                                                    size_9 size_10 size_11 size_12 size_13
        discount_price purchase_sale_type created_at expiry_date extra_expence extra_quantity gst gst_amount],
                                                  follow_ups_attributes: %i[id reminder_type task_type priority created_by
                                                                            assigned_to_id date comment followable_id
                                                                            followable_type]
      )
  end

  def download_sale_deals_pdf_file
    @sale_deals = @q.result
    sorted_data
    generate_pdf(@sorted_data.as_json, 'Sale Deal', 'pdf.html', 'A4', false, 'sale_deals/index.pdf.erb')
  end

  def download_sale_deals_csv_file
    @sale_deals = @q.result
    header_for_csv = %w[deal_date name number type_of_plot plot_size project_name form_no ms_no type]
    data_for_csv = get_data_for_sale_deals_csv
    generate_csv(data_for_csv, header_for_csv, 'SaleDeals')
  end

  def show_sale_pdf
    request.format = 'pdf'
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: 'sale_deal-pdf',
               template: 'sale_deals/show.pdf.erb',
               page_size: 'A4',
               orientation: 'Portrait',
               margin: {
                 margin_top: @pos_setting&.pdf_margin_top.to_f,
                 margin_right: @pos_setting&.pdf_margin_right.to_f,
                 margin_bottom: @pos_setting&.pdf_margin_bottom.to_f,
                 margin_left: @pos_setting&.pdf_margin_left.to_f
               },
               encoding: 'UTF-8',
               footer: {
                 right: '[page] of [topage]'
               },
               show_as_html: false
      end
    end
  end

  def approve_requested_deal
    @sale_deal.update(status: 'Clear')
    redirect_to request.referrer, notice: 'Sale Deal was approved successfully.'
  end

end
