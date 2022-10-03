class WarrantiesController < ApplicationController
  before_action :set_warranty, only: [:show, :edit, :update, :destroy]

  # GET /warranties
  # GET /warranties.json
  def index
    @created_at_gteq = DateTime.now - 1.month
    @created_at_lteq = DateTime.now


    if params[:q].present?
      @title = params[:q][:comment_or_serial_number_cont]
      @created_at_gteq = params[:q][:created_at_gteq] if params[:q][:created_at_gteq]
      @created_at_lteq = params[:q][:created_at_lteq] if params[:q][:created_at_lteq]
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?


    end
    @q = Warranty.where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).ransack(params[:q])
    @warranties=@q.result(distinct: true)
    #@q = Product.ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = 'id asc' if @q.sorts.empty?
    end
    @warranty_search=Warranty.all
    @product = Product.all




    if params[:submit_pdf_staff_with].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @warranties=@q.result(distinct: true)
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
          footer:  {             # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
            right: '[page] of [topage]'},
          encoding: "UTF-8",
          show_as_html: false
        end
      end
    end

  end

  # GET /warranties/1
  # GET /warranties/1.json
  def show
    @product = Product.all

  end

  # GET /warranties/new
  def new
    @warranty = Warranty.new
    @product = Product.all
  end

  # GET /warranties/1/edit
  def edit
    @product = Product.all

  end

  # POST /warranties
  # POST /warranties.json
  def create
    @warranty = Warranty.new(warranty_params)

    respond_to do |format|
      if @warranty.save
        format.html { redirect_to warranties_path, notice: 'Warranty was successfully created.' }
        format.json { render :show, status: :created, location: @warranty }
      else
        format.html { render :new }
        format.json { render json: @warranty.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /warranties/1
  # PATCH/PUT /warranties/1.json
  def update
    respond_to do |format|
      if @warranty.update(warranty_params)
        format.html { redirect_to warranties_path, notice: 'Warranty was successfully updated.' }
        format.json { render :show, status: :ok, location: @warranty }
      else
        format.html { render :edit }
        format.json { render json: @warranty.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /warranties/1
  # DELETE /warranties/1.json
  def destroy
    @warranty.destroy
    respond_to do |format|
      format.html { redirect_to warranties_url, notice: 'Warranty was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_warranty
      @warranty = Warranty.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def warranty_params
      params.require(:warranty).permit(:serial_number, :content, :product_id)
    end
end
