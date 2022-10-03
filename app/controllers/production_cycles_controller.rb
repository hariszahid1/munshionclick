class ProductionCyclesController < ApplicationController
  before_action :set_production_cycle, only: [:show, :edit, :update, :destroy, :edit_jalai, :edit_nakasi, :show_jalai, :show_nakasi]

  # GET /production_cycles
  # GET /production_cycles.json
  def index
    @departments=Department.all
    @raw_products = RawProduct.all
    @book_date_gteq = Date.today.prev_occurring(:thursday)
    @book_date_lteq = DateTime.now
    @q = ProductionCycle.where(status:"bhari").ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = 'id desc' if @q.sorts.empty?
    end
    if params[:q].present?
      @title = params[:q][:comment_cont]
      @book_date_gteq = params[:q][:start_date_gteq] if params[:q][:start_date_gteq].present?
      @book_date_lteq = params[:q][:start_date_lteq] if params[:q][:start_date_lteq].present?
    end
    @production_cycles = @q.result(distinct: true).page(params[:page])
    if params[:submit_pdf_staff_with].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @production_cycles=@q.result(distinct: true)
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
    elsif params[:email].present?
      @pos_setting=PosSetting.first
      @production_cycles = @q.result
      @pdf_pather=render_to_string(:pdf => "Daily by Bharai",:template => 'production_cycles/index.pdf.erb',:filename => 'Daily by Bharai')
    end
    if params[:page_pdf].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @production_cycles=@q.result(distinct: true)
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: 'bharai_page',
          layout: 'bharai_page.pdf',
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

    if params[:email].present?
      @pos_setting=PosSetting.first
      subject = "#{@pos_setting.display_name} - Daily by Bharai"
      email = current_user.superAdmin.email_to.present? ? current_user.superAdmin.email_to : "info@munshionclick.com"
      pdf=[[@pdf_pather,'Daily_by_Bharai']]
      ReportMailer.new_report_email(pdf,subject,email,"").deliver
      return redirect_to production_cycles_path
    end
  end

  def index_jalai

    @date_gteq = DateTime.now-36000
    @date_lteq = DateTime.now
    @purchase_sale_detail_list = PurchaseSaleDetail.where(:transaction_type=>"Purchase").where(created_at: @date_gteq.to_date.beginning_of_day..@date_lteq.to_date.end_of_day).order('id desc')
    @jalai_a_quantity= ProductionBlock.where(status:"jalai").group(:purchase_sale_detail_id).sum(:jalai_a_quantity)
    @jalai_b_quantity= ProductionBlock.where(status:"jalai").group(:purchase_sale_detail_id).sum(:jalai_b_quantity)
    @purchase_sale_detail=Array.new
    @purchase_sale_detail_list.each do |purchase_sale_detail|
      if purchase_sale_detail.purchase_item_measurement_quantity>0
      	if ((((purchase_sale_detail.purchase_item_per_cost.last)-(@jalai_b_quantity[purchase_sale_detail.id].to_f+@jalai_a_quantity[purchase_sale_detail.id].to_f)).round(0))/purchase_sale_detail.purchase_item_measurement_quantity).round(2)>0 || ((((purchase_sale_detail.purchase_item_per_cost.last)-(@jalai_b_quantity[purchase_sale_detail.id].to_f+@jalai_a_quantity[purchase_sale_detail.id].to_f)).round(0))/purchase_sale_detail.purchase_item_measurement_quantity).round(2)<0
        	@purchase_sale_detail << purchase_sale_detail
      	end
      end
    end

    @departments=Department.all
    @raw_products = RawProduct.all
    @book_date_gteq = DateTime.now-60
    @book_date_lteq = DateTime.now

    if params[:q].present?
      @title = params[:q][:comment_cont]
      @book_date_gteq = params[:q][:start_date_gteq] if params[:q][:start_date_gteq].present?
      @book_date_lteq = params[:q][:start_date_lteq] if params[:q][:start_date_lteq].present?
      @q = ProductionCycle.where(start_date: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.beginning_of_day,status:"jalai").ransack(params[:q])
    else
      @q = ProductionCycle.where(start_date: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.beginning_of_day,status:"jalai").ransack(params[:q])

    end
    if @q.result.count > 0
      @q.sorts = 'start_date desc' if @q.sorts.empty?
    end
        bhari_daily_bricks=ProductionBlock.where(date: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,status:"bhari").pluck(:id)
        nakasi_daily_bricks=ProductionBlock.where(date: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,status:"nakasi").pluck(:id)
        jalai_daily_bricks=ProductionBlock.distinct.pluck(:bhari_production_block_id).compact
        @jalai_uncomplete_daily_bricks=ProductionBlock.where(production_status:"Uncomplete").distinct.pluck(:bhari_production_block_id).compact
        @jalai_complete_daily_bricks=ProductionBlock.where(production_status:"Complete").distinct.pluck(:bhari_production_block_id).compact
        all_ids=(bhari_daily_bricks-jalai_daily_bricks-nakasi_daily_bricks)+(@jalai_uncomplete_daily_bricks-@jalai_complete_daily_bricks)
        @bhari_daily_bricks = ProductionBlock.where(id: all_ids).order(:date).limit(10)
    if @q.result.count > 0
      @q.sorts = 'start_date desc' if @q.sorts.empty?
    end
    @production_cycles = @q.result(distinct: true).page(params[:page])
    if params[:submit_pdf_staff_with].present?
      @pos_setting=PosSetting.first

      @production_cycles=@q.result(distinct: true)
      request.format = 'pdf'
    elsif params[:email].present?
        @pos_setting=PosSetting.first
        @production_cycles = @q.result
        @pdf_pather=render_to_string(:pdf => "Daily by Jalai",:template => 'production_cycles/index_jalai.pdf.erb',:filename => 'Daily by Jalai')
    end
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Daily Nakasi Page",
        layout: 'pdf.html',
        page_size: 'A4',
        margin_top: '0',
        margin_right: '0',
        margin_bottom: '0',
        margin_left: '0',
        encoding: "UTF-8",
        footer:  {             # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
          right: '[page] of [topage]'},
        :orientation => 'Landscape',
        show_as_html: false
      end
    end

    if params[:email].present?
      @pos_setting=PosSetting.first
      subject = "#{@pos_setting.display_name} - Daily by Jalai"
      email = current_user.superAdmin.email_to.present? ? current_user.superAdmin.email_to : "info@munshionclick.com"
      pdf=[[@pdf_pather,'Daily_by_Jalai']]
      ReportMailer.new_report_email(pdf,subject,email,"").deliver
      return redirect_to jalai_production_cycles_path
    end
  end

  def index_nakasi
    @products = Product.where.not(raw_product_id:nil)

    @date_gteq = DateTime.now-60
    @date_lteq = DateTime.now
    @purchase_sale_detail = PurchaseSaleDetail.where(:transaction_type=>"Purchase").where(created_at: @date_gteq.to_date.beginning_of_day..@date_lteq.to_date.end_of_day).order('id asc')
    @jalai_a_quantity= ProductionBlock.where(status:"jalai").group(:purchase_sale_detail_id).sum(:jalai_a_quantity)
    @jalai_b_quantity= ProductionBlock.where(status:"jalai").group(:purchase_sale_detail_id).sum(:jalai_b_quantity)

    @departments=Department.all
    @raw_products = RawProduct.all
    @book_date_gteq = Date.today.prev_occurring(:thursday)
    @book_date_lteq = DateTime.now
    @q = ProductionCycle.where(status:"nakasi").ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = 'start_date desc' if @q.sorts.empty?
    end
    if params[:q].present?
      @title = params[:q][:comment_cont]
      @book_date_gteq = params[:q][:start_date_gteq] if params[:q][:start_date_gteq].present?
      @book_date_lteq = params[:q][:start_date_lteq] if params[:q][:start_date_lteq].present?
    end
    # bhari_daily_bricks=ProductionBlock.where(date: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,status:"bhari").pluck(:id)
    nakasi_daily_bricks=ProductionBlock.where(status: :nakasi).distinct.pluck(:bhari_production_block_id).compact
    # jalai_daily_bricks=ProductionBlock.where(status: :jalai).distinct.pluck(:bhari_production_block_id).compact
    @jalai_uncomplete_daily_bricks = ProductionBlock.where(production_status:"Uncomplete").distinct.pluck(:bhari_production_block_id).compact
    @jalai_complete_daily_bricks = ProductionBlock.where(production_status:"Complete").distinct.pluck(:bhari_production_block_id).compact
    all_ids = @jalai_complete_daily_bricks-((nakasi_daily_bricks).uniq)
    @bhari_daily_bricks = ProductionBlock.where(id: all_ids).limit(100)
    @production_cycles = @q.result(distinct: true).page(params[:page])
    @p=Staff.where(department_id: @departments.third.id).ransack()

    if params[:submit_pdf_staff_with].present?
      @pos_setting=PosSetting.first
      if @q.result.count > 0
        @q.sorts = 'start_date desc' if @q.sorts.empty?
      end
      @production_cycles=@q.result(distinct: true)
      request.format = 'pdf'
    elsif params[:email].present?
      @pos_setting=PosSetting.first
      @production_cycles = @q.result
      @pdf_pather=render_to_string(:pdf => "Daily by nakasi",:template => 'production_cycles/index_nakasi.pdf.erb',:filename => 'Daily by Nakasi')
    end
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Daily_by_Nakasi",
        layout: 'pdf.html',
        page_size: 'A4',
        margin_top: '0',
        margin_right: '0',
        margin_bottom: '0',
        margin_left: '0',
        encoding: "UTF-8",
        footer:  {             # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
          right: '[page] of [topage]'},
        orientation: 'Landscape',
        show_as_html: false
      end
    end
    if params[:page_pdf].present?
      @pos_setting=PosSetting.first
      if @q.result.count > 0
        @q.sorts = 'date desc' if @q.sorts.empty?
      end
      @staffs_pdf=@p.result(distinct: true)
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: "nakasi_page",
          layout: 'nakasi_page.pdf',
          page_size: 'A4',
          margin_top: '0',
          margin_right: '0',
          margin_bottom: '0',
          margin_left: '0',
          encoding: "UTF-8",
          footer:  {             # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
            right: '[page] of [topage]'},
          orientation: 'Landscape',
          show_as_html: false
        end
      end
   end

   if params[:email].present?
      @pos_setting=PosSetting.first
      subject = "#{@pos_setting.display_name} - Daily by Nakasi"
      email = current_user.superAdmin.email_to.present? ? current_user.superAdmin.email_to : "info@munshionclick.com"
      pdf=[[@pdf_pather,'Daily_by_Nakasi']]
      ReportMailer.new_report_email(pdf,subject,email,"").deliver
      return redirect_to nakasi_production_cycles_path
    end
  end
  # GET /production_cycles/1
  # GET /production_cycles/1.json
  def show
  end

  def show_jalai
    @raw_products = RawProduct.all
    @production_block_types = ProductionBlockType.all
    @items = Item.having('measurement_quantity>0')
    @date_gteq = DateTime.now-60
    @date_lteq = DateTime.now
    @purchase_sale_detail = PurchaseSaleDetail.where(:transaction_type=>"Purchase").where(created_at: @date_gteq.to_date.beginning_of_day..@date_lteq.to_date.end_of_day).order('id desc')
    @jalai_a_quantity= ProductionBlock.where(status:"jalai").group(:purchase_sale_detail_id).sum(:jalai_a_quantity)
    @jalai_b_quantity= ProductionBlock.where(status:"jalai").group(:purchase_sale_detail_id).sum(:jalai_b_quantity)
    @total_bricks=0
    @total_tiles=0
    @production_cycle.production_blocks.each do |production_block|
      bhari_production_block=ProductionBlock.find_by_id(production_block.bhari_production_block_id)
      production_block.bricks_quantity= bhari_production_block.bricks_quantity
      production_block.tiles_quantity= bhari_production_block.tiles_quantity
      @total_bricks+=production_block.bricks_quantity.to_i
      @total_tiles+=production_block.tiles_quantity.to_i
    end
    array = @production_cycle.production_blocks.pluck(:production_status)
    @uncompleted = array.select{|word| word.length > 8 }

  end

  def show_nakasi

    redirect_to nakasi_production_cycles_path unless params[:bhari_daily].present?
    @production_cycle = ProductionCycle.new
    @jalai_a_quantity= ProductionBlock.where(status:"jalai").group(:purchase_sale_detail_id).sum(:jalai_a_quantity)
    @jalai_b_quantity= ProductionBlock.where(status:"jalai").group(:purchase_sale_detail_id).sum(:jalai_b_quantity)
    @production_block_types = ProductionBlockType.all
    if params[:bhari_daily]
      @line_count=0
      @total_bricks=0
      @total_tiles=0
      un_line=0
      params[:bhari_daily].each do |bhari_daily|
        production_block = ProductionBlock.find_by_id(bhari_daily.first)
        @line_count+=1;
        @production_cycle.start_date = DateTime.now
        @production_cycle.status = "jalai"
        bricks_quantity=(production_block.bricks_quantity.to_f)
        tiles_quantity=(production_block.tiles_quantity.to_f)
        @production_cycle.production_blocks.build(title:production_block.title,bricks_quantity: bricks_quantity, tiles_quantity: tiles_quantity, bhari_production_block_id:production_block.id,jalai_a:0,jalai_b:0,date:DateTime.now)
        @total_bricks+=bricks_quantity
        @total_tiles+=tiles_quantity
      end
      @production_cycle.lines=(@line_count*2)-un_line;
    end

  end


  # GET /production_cycles/new
  def new
    @production_cycle = ProductionCycle.new
    @raw_products = RawProduct.all
    @production_block_types = ProductionBlockType.all
  end

  def new_jalai
    redirect_to jalai_production_cycles_path unless params[:bhari_daily].present?
    @jalai_uncomplete_daily_bricks=ProductionBlock.where(production_status:"Uncomplete").distinct.pluck(:bhari_production_block_id).compact
    @items = Item.having('measurement_quantity>0')
    @production_cycle = ProductionCycle.new
    @raw_products = RawProduct.all
    @date_gteq = DateTime.now-100
    @date_lteq = DateTime.now
    @purchase_sale_detail_list = PurchaseSaleDetail.where(:transaction_type=>"Purchase").where(created_at: @date_gteq.to_date.beginning_of_day..@date_lteq.to_date.end_of_day).order('id asc')
    @jalai_a_quantity= ProductionBlock.where(status:"jalai").group(:purchase_sale_detail_id).sum(:jalai_a_quantity)
    @jalai_b_quantity= ProductionBlock.where(status:"jalai").group(:purchase_sale_detail_id).sum(:jalai_b_quantity)
    @purchase_sale_detail=Array.new
    @purchase_sale_detail_list.each do |purchase_sale_detail|
      if purchase_sale_detail.purchase_item_measurement_quantity>0
        if ((((purchase_sale_detail.purchase_item_per_cost.last)-(@jalai_b_quantity[purchase_sale_detail.id].to_f+@jalai_a_quantity[purchase_sale_detail.id].to_f)).round(0))/purchase_sale_detail.purchase_item_measurement_quantity).round(2)>0 || ((((purchase_sale_detail.purchase_item_per_cost.last)-(@jalai_b_quantity[purchase_sale_detail.id].to_f+@jalai_a_quantity[purchase_sale_detail.id].to_f)).round(0))/purchase_sale_detail.purchase_item_measurement_quantity).round(2)<0
          @purchase_sale_detail << purchase_sale_detail
        end
      end
    end

    @production_block_types = ProductionBlockType.all
    if params[:bhari_daily]
      @line_count=0
      @total_bricks=0
      @total_tiles=0
      un_line=0
      params[:bhari_daily].each do |bhari_daily|
        production_block = ProductionBlock.find_by_id(bhari_daily.first)
        @line_count+=1;
        @production_cycle.start_date = DateTime.now
        @production_cycle.status = "jalai"
        bricks_quantity=(production_block.bricks_quantity.to_f)
        tiles_quantity=(production_block.tiles_quantity.to_f)
        if params[:status][bhari_daily.first]=="Uncomplete"
          @production_cycle.production_blocks.build(title:production_block.title,bricks_quantity: bricks_quantity, tiles_quantity: tiles_quantity, bhari_production_block_id:production_block.id,jalai_a:0,jalai_b:0,date:DateTime.now,production_status: "Uncomplete", comment: "remove-uncomplete")
        else
          @production_cycle.production_blocks.build(title:production_block.title,bricks_quantity: bricks_quantity, tiles_quantity: tiles_quantity, bhari_production_block_id:production_block.id,jalai_a:0,jalai_b:0,date:DateTime.now)
        end
        @total_bricks+=bricks_quantity
        @total_tiles+=tiles_quantity
      end
      params[:status].each do |status|
        un_line+=1 if status.last=="Uncomplete"
      end
      @production_cycle.lines=(@line_count*2)-un_line;
    end
  end


  def new_nakasi
    redirect_to nakasi_production_cycles_path unless params[:bhari_daily].present?
    @production_cycle = ProductionCycle.new
    @jalai_a_quantity= ProductionBlock.where(status:"jalai").group(:purchase_sale_detail_id).sum(:jalai_a_quantity)
    @jalai_b_quantity= ProductionBlock.where(status:"jalai").group(:purchase_sale_detail_id).sum(:jalai_b_quantity)
    @production_block_types = ProductionBlockType.all
    if params[:bhari_daily]
      @line_count=0
      @total_bricks=0
      @total_tiles=0
      un_line=0
      params[:bhari_daily].each do |bhari_daily|
        production_block = ProductionBlock.find_by_id(bhari_daily.first)
        @line_count+=1;
        @production_cycle.start_date = DateTime.now
        @production_cycle.status = "jalai"
        bricks_quantity=(production_block.bricks_quantity.to_f)
        tiles_quantity=(production_block.tiles_quantity.to_f)
        @production_cycle.production_blocks.build(title:production_block.title,bricks_quantity: bricks_quantity, tiles_quantity: tiles_quantity, bhari_production_block_id:production_block.id,jalai_a:0,jalai_b:0,date:DateTime.now)
        @total_bricks+=bricks_quantity
        @total_tiles+=tiles_quantity
      end
      @production_cycle.lines=(@line_count*2)-un_line;
    end
  end
  # GET /production_cycles/1/edit
  def edit
    @raw_products = RawProduct.all
    @production_block_types = ProductionBlockType.all
  end

  def edit_jalai
    @raw_products = RawProduct.all
    @production_block_types = ProductionBlockType.all
    @items = Item.having('measurement_quantity>0')
    @date_gteq = DateTime.now-36000
    @date_lteq = DateTime.now
    @purchase_sale_detail = PurchaseSaleDetail.where(:transaction_type=>"Purchase").where(created_at: @date_gteq.to_date.beginning_of_day..@date_lteq.to_date.end_of_day).order('id desc')
    @jalai_a_quantity= ProductionBlock.where(status:"jalai").group(:purchase_sale_detail_id).sum(:jalai_a_quantity)
    @jalai_b_quantity= ProductionBlock.where(status:"jalai").group(:purchase_sale_detail_id).sum(:jalai_b_quantity)
    @total_bricks=0
    @total_tiles=0
    @production_cycle.production_blocks.each do |production_block|
      bhari_production_block=ProductionBlock.find_by_id(production_block.bhari_production_block_id)
      production_block.bricks_quantity= bhari_production_block.bricks_quantity
      production_block.tiles_quantity= bhari_production_block.tiles_quantity
      @total_bricks+=production_block.bricks_quantity.to_i
      @total_tiles+=production_block.tiles_quantity.to_i
    end
    @jalai_uncomplete_daily_bricks=ProductionBlock.where(production_status:"Uncomplete").distinct.pluck(:bhari_production_block_id).compact
    array = @production_cycle.production_blocks.pluck(:production_status)
    @uncompleted = array.select{|word| word.length > 8 }
  end

  def edit_nakasi
    @raw_products = RawProduct.all
    @production_block_types = ProductionBlockType.all
    @jalai_a_quantity= ProductionBlock.where(status:"jalai").group(:purchase_sale_detail_id).sum(:jalai_a_quantity)
    @jalai_b_quantity= ProductionBlock.where(status:"jalai").group(:purchase_sale_detail_id).sum(:jalai_b_quantity)
    @total_bricks=0
    @total_tiles=0
    @production_cycle.production_blocks.each do |production_block|
      bhari_production_block=ProductionBlock.find_by_id(production_block.bhari_production_block_id)
      if bhari_production_block.present?
        production_block.bricks_quantity= bhari_production_block.bricks_quantity
        production_block.tiles_quantity= bhari_production_block.tiles_quantity
        @total_bricks+=production_block.bricks_quantity.to_i
        @total_tiles+=production_block.tiles_quantity.to_i
      end
    end
    array = @production_cycle.production_blocks.pluck(:production_status)
    @uncompleted = array.select{|word| word.length > 8 }
  end
  # POST /production_cycles
  # POST /production_cycles.json
  def create
    @production_cycle = ProductionCycle.new(production_cycle_params)
    @production_cycle.production_blocks.each do |production_block|
      if production_block.comment=="remove-uncomplete"
        production_block.production_status= "Complete"
      end
    end

    respond_to do |format|
      if @production_cycle.save
        bricks=RawProduct.first
        tiles=RawProduct.second
        if @production_cycle.status=="jalai"
          format.html { redirect_to jalai_production_cycles_url, notice: 'Production cycle was successfully created.' }
        elsif @production_cycle.status=="bhari"
          bricks.first_stock-=@production_cycle.production_blocks_bricks_quantity
          bricks.save
          tiles.first_stock-=@production_cycle.production_blocks_tiles_quantity
          tiles.save
          format.html { redirect_to production_cycles_url, notice: 'Production cycle was successfully created.' }
        elsif @production_cycle.status=="nakasi"
          bricks.nakasi_stock+=@production_cycle.production_blocks_bricks_quantity
          bricks.save
          tiles.nakasi_stock+=@production_cycle.production_blocks_tiles_quantity
          tiles.save
          format.html { redirect_to nakasi_production_cycles_url, notice: 'Production cycle was successfully created.' }
        end
        format.json { render :show, status: :created, location: @production_cycle }
      else
        @production_cycle = ProductionCycle.new
        @raw_products = RawProduct.all
        @production_block_types = ProductionBlockType.all
        @items = Item.having('measurement_quantity>0')
        format.html { render :new }
        format.json { render json: @production_cycle.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /production_cycles/1
  # PATCH/PUT /production_cycles/1.json
  def update

    respond_to do |format|
      bricks_quantity=0
      tiles_quantity=0
      production_cycle_params[:production_blocks_attributes].each do |production_cycle|
        if production_cycle[1]["_destroy"]=="false"
          bricks_quantity += production_cycle[1][:bricks_quantity].to_i
          tiles_quantity += production_cycle[1][:tiles_quantity].to_i
        end
      end
      bricks_quantity_was = @production_cycle.production_blocks_bricks_quantity
      tiles_quantity_was = @production_cycle.production_blocks_tiles_quantity
      if @production_cycle.update(production_cycle_params)
        bricks=RawProduct.first
        tiles=RawProduct.second
        if @production_cycle.status=="jalai"
          format.html { redirect_to jalai_production_cycles_url, notice: 'Production cycle was successfully updated.' }
        elsif @production_cycle.status=="bhari"
          bricks.first_stock +=bricks_quantity_was.to_i-bricks_quantity.to_i
          tiles.first_stock +=tiles_quantity_was.to_i-tiles_quantity.to_i
          bricks.save
          tiles.save
          format.html { redirect_to production_cycles_url, notice: 'Production cycle was successfully updated.' }
        elsif @production_cycle.status=="nakasi"
          format.html { redirect_to nakasi_production_cycles_url, notice: 'Production cycle was successfully updated.' }
        end
        format.json { render :show, status: :ok, location: @production_cycle }
      else
        @raw_products = RawProduct.all
        @production_block_types = ProductionBlockType.all
        @items = Item.having('measurement_quantity>0')
        format.html { render :edit }
        format.json { render json: @production_cycle.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /production_cycles/1
  # DELETE /production_cycles/1.json
  def destroy
    bricks=RawProduct.first
    tiles=RawProduct.second
    if @production_cycle.status=="bhari"
      bricks.first_stock+=@production_cycle.production_blocks_bricks_quantity
      tiles.first_stock+=@production_cycle.production_blocks_tiles_quantity
      bricks.save
      tiles.save
    elsif @production_cycle.status=="nakasi"
      bricks.nakasi_stock-=@production_cycle.production_blocks_bricks_quantity
      bricks.save
      tiles.nakasi_stock-=@production_cycle.production_blocks_tiles_quantity
      tiles.save
    end
    @production_cycle.destroy!

    respond_to do |format|
      if @production_cycle.status=="jalai"
        format.html { redirect_to jalai_production_cycles_url, notice: 'Production cycle was successfully destroyed.' }
      elsif @production_cycle.status=="bhari"
        format.html { redirect_to production_cycles_url, notice: 'Production cycle was successfully destroyed.' }
      elsif @production_cycle.status=="nakasi"
        format.html { redirect_to nakasi_production_cycles_url, notice: 'Production cycle was successfully destroyed.' }
      end
      format.json { head :no_content }
      format.js   { render :layout => false }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_production_cycle
      @production_cycle = ProductionCycle.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def production_cycle_params
      params.require(:production_cycle).permit(:start_date, :end_date, :status, :comment, :cycle_type, :item_id, :cost, :total_cost, :quantity, :lines, :cost_per_line, :per_product_cost, :per_thousand_product_cost, :item_quantity_per_line, :total_item_quantity, :per_ton_bricks, :total_bricks,
      production_blocks_attributes:[:id, :production_block_type_id, :title, :bricks_quantity, :tiles_quantity, :date, :status, :comment, :production_cycle_id, :jalai_a, :jalai_b, :production_status, :purchase_sale_detail_id, :jalai_a_quantity, :jalai_b_quantity, :bhari_production_block_id, :_destroy])
    end
end
