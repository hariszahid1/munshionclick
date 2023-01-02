class SaleDealsController < ApplicationController
  before_action :set_sale_deal, only: %i[show edit update destroy]
  before_action :set_data, only: %i[new edit create update show]

  # GET /sale_deals
  # GET /sale_deals.json
  def index
    @q = PurchaseSaleDetail.ransack(params[:q])
    @sale_deals = @q.result.where(transaction_type: 'SaleDeal')
  end

  # GET /sale_deals/1
  # GET /sale_deals/1.json
  def show
    request.format = 'pdf'
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: 'order-dynamic-pdf',
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

  # GET /sale_deals/new
  def new
    @sale_deal = PurchaseSaleDetail.new
    @sale_deal.purchase_sale_items.build
  end

  # GET /sale_deals/1/edit
  def edit; end

  # POST /sale_deals
  # POST /sale_deals.json
  def create
    @sale_deal = PurchaseSaleDetail.new(sale_deal_params)
    respond_to do |format|
      if @sale_deal.save
        format.js
        format.html { redirect_to sale_deals_path, notice: 'Sale Deal was successfully created.' }
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
    respond_to do |format|
     
      if @sale_deal.update(sale_deal_params)

        format.html { redirect_to sale_deals_path, notice: 'Sale Deal was successfully updated.' }
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
    @sale_dealsa.destroy
    respond_to do |format|
      format.html { redirect_to sale_deals_url, notice: 'Sale Deal was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_sale_deal
    @sale_deal = PurchaseSaleDetail.find(params[:id])
  end

  def set_data
    @sys_users = SysUser.all.where(for_crms: [false, nil])
    @accounts = Account.all
    @products = Product.all
    created_by_ids = current_user.created_by_ids_list_to_view
    @all_agents = User.where('company_type=? or created_by_id=?', current_user.company_type, created_by_ids).pluck(:name,
      :id)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def sale_deal_params
    params.require(:purchase_sale_detail).permit(:sys_user_id, :transaction_type, :total_bill, :amount, :discount_price,
                                                  :status, :comment, :voucher_id, :created_at, :account_id, :carriage,
                                                  :loading, :order_id, :created_at, :staff_id, :bill_no, :user_name,
                                                  :destination, :l_c, :g_d, :g_d_type, :g_d_date, :quantity, :dispatched_to,
                                                  :despatch_date, :job_no, :reference_no, :company_name, :with_gst,
                                                  purchase_sale_items_attributes: %i[id purchase_sale_detail_id item_id
                                                                                    product_id quantity cost_price sale_pricestatuscomment
                                                                                    total_cost_price total_sale_price transaction_type
                                                                                    size_1 size_2 size_3 size_4 size_5 size_6 size_7 size_8
                                                                                    size_9 size_10 size_11 size_12 size_13
        discount_price purchase_sale_type created_at expiry_date extra_expence extra_quantity gst gst_amount
      ])
  end
end
