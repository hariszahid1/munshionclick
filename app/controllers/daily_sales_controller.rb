class DailySalesController < ApplicationController
	before_action :check_access
  before_action :set_daily_sale, only: [:show, :edit, :update, :destroy]

  # GET /daily_sales
  # GET /daily_sales.json
  def index

      @q = DailySale.ransack(params[:q])

    if @q.result.count > 0
      @q.sorts = 'id desc' if @q.sorts.empty?
    end
    @daily_sales = @q.result(distinct: true).page(params[:page])
    if params[:submit_pdf_staff_with].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @daily_sales=@q.result(distinct: true)
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
          show_as_html: true
        end
      end
    end
  end

  # GET /daily_sales/1
  # GET /daily_sales/1.json
  def show
  end

  # GET /daily_sales/new
  def new
    @daily_sale = DailySale.new
  end

  # GET /daily_sales/1/edit
  def edit
  end

  # POST /daily_sales
  # POST /daily_sales.json
  def create
    @daily_sale = DailySale.new(daily_sale_params)

    respond_to do |format|
      if @daily_sale.save
        format.html { redirect_to daily_sales_url, notice: 'Daily sale was successfully created.' }
        format.json { render :show, status: :created, location: @daily_sale }
      else
        format.html { render :new }
        format.json { render json: @daily_sale.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /daily_sales/1
  # PATCH/PUT /daily_sales/1.json
  def update
    respond_to do |format|
      if @daily_sale.update(daily_sale_params)
        format.html { redirect_to daily_sales_url, notice: 'Daily sale was successfully updated.' }
        format.json { render :show, status: :ok, location: @daily_sale }
      else
        format.html { render :edit }
        format.json { render json: @daily_sale.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /daily_sales/1
  # DELETE /daily_sales/1.json
  def destroy
    @daily_sale.destroy
    respond_to do |format|
      format.html { redirect_to daily_sales_url, notice: 'Daily sale was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_daily_sale
      @daily_sale = DailySale.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def daily_sale_params
      params.require(:daily_sale).permit(:sale, :cash_out, :shift, :comment, :created_at, :updated_at)
    end
end
