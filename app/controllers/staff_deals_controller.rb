class StaffDealsController < ApplicationController
  before_action :check_access
  before_action :set_staff_deal, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_user!, only: [:index]

  # GET /staff_deals
  # GET /staff_deals.json
  def index
    @created_at_gteq = DateTime.now-10000
    @created_at_lteq = DateTime.now
    @staffs = Department.find_by(title:'Dealer')&.staffs || Staff.all
    @products = Product.all
    @product_categories = ProductCategory.all
    @product_sub_categories = ProductSubCategory.all
    @item_types = ItemType.all
    @q=StaffDeal.joins(:product).ransack(params[:q])
    @status=''
    if params[:q].present?
      @status=params[:q][:product_size_6_in]
      params[:q][:product_size_6_in]=nil
      if @status=="0"
        booked_plot = Product.booked_plot
        @q = StaffDeal.joins(:product).where(product_id: booked_plot).ransack(params[:q])
      elsif @status=="1"
        open_plots = Product.open_plot
        @q = StaffDeal.joins(:product).where(product_id: open_plots).ransack(params[:q])
      elsif @status=="2"
        secure_plot = Product.secure_plot
        @q = StaffDeal.joins(:product).where(product_id: open_plots).ransack(params[:q])
      elsif @status=="3"
        only_booked_plot = Product.only_booked_plot
        @q = StaffDeal.joins(:product).where(product_id: only_booked_plot).ransack(params[:q])
      end
      params[:q][:size_6_in]=@status
    end
    if @q.result.count > 0
      @q.sorts = ['id desc', 'created_at desc'] if @q.sorts.empty?
    end
    @staff_deals = @q.result(distinct: true).page(params[:page]).per(100)
    if params[:submit_pdf].present?
      if @q.result.count > 0
        @q.sorts = ['id desc', 'created_at desc'] if @q.sorts.empty?
      end

      @staff_deals=@q.result(distinct: true)
      print_pdf('DealerList', 'pdf.html','A4')
    end

  
  end

  # GET /staff_deals/1
  # GET /staff_deals/1.json
  def show
  end

  # GET /staff_deals/new
  def new
    @staffs = Staff.all
    @products = Product.all
    @staff_deal = StaffDeal.new
  end

  # GET /staff_deals/1/edit
  def edit
    @staffs = Staff.all
    @products = Product.all
  end

  # POST /staff_deals
  # POST /staff_deals.json
  def create
    @staff_deal = StaffDeal.new(staff_deal_params)

    respond_to do |format|
      if @staff_deal.save
        format.html { redirect_to staff_deals_url, notice: 'Staff deal was successfully created.' }
        format.json { render :show, status: :created, location: @staff_deal }
      else
        @staffs = Staff.all
        @products = Product.all
        format.html { render :new }
        format.json { render json: @staff_deal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /staff_deals/1
  # PATCH/PUT /staff_deals/1.json
  def update
    respond_to do |format|
      if @staff_deal.update(staff_deal_params)
        format.html { redirect_to staff_deals_url, notice: 'Staff deal was successfully updated.' }
        format.json { render :show, status: :ok, location: @staff_deal }
      else
        @staffs = Staff.all
        @products = Product.all
        format.html { render :edit }
        format.json { render json: @staff_deal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /staff_deals/1
  # DELETE /staff_deals/1.json
  def destroy
    @staff_deal.destroy
    respond_to do |format|
      format.html { redirect_to staff_deals_url, notice: 'Staff deal was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_staff_deal
      @staff_deal = StaffDeal.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def staff_deal_params
      params.require(:staff_deal).permit(:staff_id, :product_id, :cost, :comment)
    end
end
