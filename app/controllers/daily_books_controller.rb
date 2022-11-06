class DailyBooksController < ApplicationController
  helper DailyBooksHelper
  before_action :set_daily_book, only: [:show, :edit, :update, :destroy,:edit_khakar, :edit_nakasi, :stock_edit_khakar]

  # GET /daily_books
  # GET /daily_books.json
  def index
    @departments=Department.all
    @book_date_gteq = Date.today.prev_occurring(:thursday)
    @book_date_lteq = DateTime.now
    if params[:q].present?
      @department = params[:q][:department_id]
      @book_date_gteq = params[:q][:book_date_gteq] if params[:q][:book_date_gteq].present?
      @book_date_lteq = params[:q][:book_date_lteq] if params[:q][:book_date_lteq].present?
      params[:q][:book_date_lteq] = params[:q][:book_date_lteq].to_date.end_of_day if params[:q][:book_date_lteq].present?
    end
    if params[:q].present?
      @q = DailyBook.where(department_id: @departments.first.id).ransack(params[:q])
    else
      @q = DailyBook.where(book_date: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,department_id: @departments.first.id).ransack()
    end

    if @q.result.count > 0
      @q.sorts = 'book_date desc' if @q.sorts.empty?
    end
    @daily_books = @q.result.page(params[:page])
    #@daily_book_salary_details_raw_quantity=@daily_books.sum(:salary_details_raw_quantity)
    #@daily_book_salary_details_f99_raw_quantity=@daily_books.sum(:salary_details_f99_raw_quantity)


    if params[:submit_pdf].present?
      @pos_setting=PosSetting.first
      if @q.result.count > 0
        @q.sorts = 'book_date desc' if @q.sorts.empty?
      end
      @daily_books=@q.result(distinct: true)
      request.format = 'pdf'
    end

    if params[:email].present?
      @pos_setting=PosSetting.first
      @daily_books = @q.result
      @pdf_pather=render_to_string(:pdf => "Daily by Pather",:template => 'daily_books/index.pdf.erb',:filename => 'Daily by Pather')
    end

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Day-Out",
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

    if params[:email].present?
      @pos_setting=PosSetting.first
      @daily_books = @q.result(distinct: true)
      subject = "#{@pos_setting.display_name} - Daily by Pather"
      email = current_user.superAdmin.email_to.present? ? current_user.superAdmin.email_to : "info@munshionclick.com"
      pdf=[[@pdf_pather,'Daily_by_pather']]
      ReportMailer.new_report_email(pdf,subject,email,"").deliver
      return redirect_to daily_books_path
    end

  end

  def index_khakar
    @staff=Staff.all
    @departments=Department.all
    @raw_products = RawProduct.all
    @book_date_gteq = Date.today.prev_occurring(:thursday)
    @book_date_lteq = DateTime.now
    @pathara_book_date_gteq = DateTime.now-50
    @pathara_book_date_lteq = DateTime.now
    if params[:q].present?
      @department = params[:q][:department_id]
      @book_date_gteq = params[:q][:book_date_gteq] if params[:q][:book_date_gteq].present?
      @book_date_lteq = params[:q][:book_date_lteq] if params[:q][:book_date_lteq].present?
      @pathara_book_date_gteq = params[:q][:book_date_gteq] if params[:q][:book_date_gteq].present?
      @pathara_book_date_lteq = params[:q][:book_date_lteq] if params[:q][:book_date_lteq].present?
      @q = DailyBook.where(created_at: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,department_id:@departments.second.id).ransack()
    else
      @q = DailyBook.where(created_at: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,department_id:@departments.second.id).ransack()
    end
    if @q.result.count > 0
      @q.sorts = 'created_at desc' if @q.sorts.empty?
    end
    @pathera_daily = DailyBook.where(book_date: @pathara_book_date_gteq.to_date.beginning_of_day..@pathara_book_date_lteq.to_date.end_of_day,department_id:@departments.first.id).order(:book_date)
    @daily_books = @q.result(distinct: true).page(params[:page]).per(60)
    if params[:submit_pdf].present?
      @pos_setting=PosSetting.first
      if @q.result.count > 0
        @q.sorts = 'book_date desc' if @q.sorts.empty?
      end
      @daily_books=@q.result(distinct: true)
      request.format = 'pdf'
    elsif params[:email].present?
        @pos_setting=PosSetting.first
        @daily_books = @q.result
        @pdf_pather=render_to_string(:pdf => "Daily by khakar",:template => 'daily_books/index_khakar.pdf.erb',:filename => 'Daily by Khakar')
    end

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Day-Out",
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
    @p=Staff.where(department_id: @departments.second.id).ransack()

  if params[:page_pdf].present?
      @pos_setting=PosSetting.first
      if @q.result.count > 0
        @q.sorts = 'book_date desc' if @q.sorts.empty?
      end
      @staffs_pdf=@p.result(distinct: true)
      request.format = 'pdf'

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "khakar_page",
        layout: 'khakar_page.pdf',
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
    @daily_books = @q.result(distinct: true)
    subject = "#{@pos_setting.display_name} - Daily by Khakar"
    email = current_user.superAdmin.email_to.present? ? current_user.superAdmin.email_to : "info@munshionclick.com"
    pdf=[[@pdf_pather,'Daily_by_khakar']]
    ReportMailer.new_report_email(pdf,subject,email,"").deliver
    return redirect_to khakar_daily_books_path
  end
end

  def index_nakasi
    @departments=Department.all
    @book_date_gteq = Date.today.prev_occurring(:thursday)
    @book_date_lteq = DateTime.now
    @raw_products = RawProduct.all
    @products = Product.all

    if params[:q].present?
      @book_date_gteq = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @book_date_lteq = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
    end

    if params[:q].present?
      @q = DailyBook.where(department_id: @departments.third.id).ransack(params[:q])
    else
      @q = DailyBook.where(created_at: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,department_id: @departments.third.id).ransack()
    end

    if @q.result.count > 0
      @q.sorts = 'created_at desc' if @q.sorts.empty?
    end
    if params[:q].present?
      @department = params[:q][:department_id]
      @book_date_gteq = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @book_date_lteq = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
    end
    @daily_books = @q.result(distinct: true).page(params[:page])
    if params[:submit_pdf].present?
      @pos_setting=PosSetting.first
      if @q.result.count > 0
        @q.sorts = 'book_date desc' if @q.sorts.empty?
      end
      @daily_books=@q.result(distinct: true)

      request.format = 'pdf'
    elsif params[:email].present?
      @pos_setting=PosSetting.first
      @daily_books = @q.result
      @pdf_pather=render_to_string(:pdf => "Daily by nakasi",:template => 'daily_books/index_nakasi.pdf.erb',:filename => 'Daily by nakasi')
    end
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Day-Out",
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

    if params[:email].present?
      @pos_setting=PosSetting.first
      @daily_books = @q.result(distinct: true)
      subject = "#{@pos_setting.display_name} - Daily by Nakasi"
      email = current_user.superAdmin.email_to.present? ? current_user.superAdmin.email_to : "info@munshionclick.com"
      pdf=[[@pdf_pather,'Daily_by_nakasi']]
      ReportMailer.new_report_email(pdf,subject,email,"").deliver
      return redirect_to nakasi_daily_books_path
    end
  end

  def production_report
    @departments=Department.all
    @raw_products = RawProduct.all
    if params[:q].present?
      @department = params[:q][:department_id]
      @book_date_gteq = params[:q][:book_date_gteq] if params[:q][:book_date_gteq].present?
      @book_date_lteq = params[:q][:book_date_lteq] if params[:q][:book_date_lteq].present?
    else
      @book_date_gteq = Date.today.prev_occurring(:thursday)
      @book_date_lteq = DateTime.now
    end
    @q = DailyBook.where(book_date: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,department_id: @departments.first.id).ransack()
    @k = DailyBook.where(created_at: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,department_id: @departments.second.id).ransack()
    @p = ProductionCycle.where(start_date: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,status:"bhari").ransack()
    @j = ProductionCycle.where(start_date: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,status:"jalai").ransack()
    @n = ProductionCycle.where(start_date: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,status:"nakasi").ransack()

    if @p.result.count > 0
      @p.sorts = 'id desc' if @q.sorts.empty?
    end
    if @j.result.count > 0
      @j.sorts = 'date desc' if @j.sorts.empty?
    end

    if @q.result.count > 0
      @q.sorts = 'book_date desc' if @q.sorts.empty?
    end
    if @k.result.count > 0
      @k.sorts = 'created_at desc' if @k.sorts.empty?
    end
    if @n.result.count > 0
      @n.sorts = 'date desc' if @n.sorts.empty?
    end
    @daily_books = @q.result
    @khakar_daily_books = @k.result
    @production_cycles = @p.result(distinct: true)
    @jalai_production_cycles = @j.result(distinct: true)
    @nkasi_production_cycles = @n.result(distinct: true)

    if params[:submit_pdf].present?
      @pos_setting=PosSetting.first
      if @q.result.count > 0
        @q.sorts = 'book_date desc' if @q.sorts.empty?
      end
      @daily_books=@q.result(distinct: true)
      @khakar_daily_books = @k.result
      @production_cycles = @p.result(distinct: true)
      @jalai_production_cycles = @j.result(distinct: true)
      @nkasi_production_cycles = @n.result(distinct: true)
      request.format = 'pdf'
    end
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "index_staff_wise",
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

  def total_production_report
    @departments=Department.all
    @raw_products = RawProduct.all
    if params[:q].present?
      @department = params[:q][:department_id]
      @book_date_gteq = params[:q][:book_date_gteq] if params[:q][:book_date_gteq].present?
      @book_date_lteq = params[:q][:book_date_lteq] if params[:q][:book_date_lteq].present?
    else
      @book_date_gteq = Date.today.prev_occurring(:thursday)
      @book_date_lteq = DateTime.now
    end

    @q = DailyBook.where(book_date: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,department_id: @departments.first.id).ransack()
    @k = DailyBook.where(created_at: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,department_id: @departments.second.id).ransack()
    @p = ProductionCycle.where(start_date: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,status:"bhari").ransack()
    @j = ProductionCycle.where(start_date: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,status:"jalai").ransack()
    @n = ProductionCycle.where(start_date: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,status:"nakasi").ransack()

    if @p.result.count > 0
      @p.sorts = 'id desc' if @q.sorts.empty?
    end
    if @j.result.count > 0
      @j.sorts = 'date desc' if @j.sorts.empty?
    end

    if @q.result.count > 0
      @q.sorts = 'book_date desc' if @q.sorts.empty?
    end
    if @k.result.count > 0
      @k.sorts = 'created_at desc' if @k.sorts.empty?
    end
    if @n.result.count > 0
      @n.sorts = 'date desc' if @n.sorts.empty?
    end
    @daily_books = @q.result
    @khakar_daily_books = @k.result
    @production_cycles = @p.result(distinct: true)
    @jalai_production_cycles = @j.result(distinct: true)
    @nkasi_production_cycles = @n.result(distinct: true)

    if params[:submit_pdf].present?
      @pos_setting=PosSetting.first
      if @q.result.count > 0
        @q.sorts = 'book_date desc' if @q.sorts.empty?
      end
      @daily_books=@q.result(distinct: true)
      @khakar_daily_books = @k.result
      @production_cycles = @p.result(distinct: true)
      @jalai_production_cycles = @j.result(distinct: true)
      @nkasi_production_cycles = @n.result(distinct: true)
      request.format = 'pdf'
    end
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "index_staff_wise",
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

  # GET /daily_books/1
  # GET /daily_books/1.json
  def show
    @departments=Department.all
    @book_date_gteq = Date.today.prev_occurring(:thursday)
    @book_date_lteq = DateTime.now
    if params[:q].present?
      @q = DailyBook.where(department_id: @departments.first.id).ransack(params[:q])
    else
      @q = DailyBook.where(book_date: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,department_id: @departments.first.id).ransack()
    end

    if @q.result.count > 0
      @q.sorts = 'book_date desc' if @q.sorts.empty?
    end
    if params[:q].present?
      @department = params[:q][:department_id]
      @book_date_gteq = params[:q][:book_date_gteq] if params[:q][:book_date_gteq].present?
      @book_date_lteq = params[:q][:book_date_lteq] if params[:q][:book_date_lteq].present?
    end
    @daily_books = @q.result.page(params[:page])
    if params[:submit_pdf].present?
      @pos_setting=PosSetting.first
      if @q.result.count > 0
        @q.sorts = 'book_date desc' if @q.sorts.empty?
      end
      @daily_books=@q.result(distinct: true)
      request.format = 'pdf'
    end
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Day-Out",
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
  def show_khakar
    @daily_book = DailyBook.find(params[:id])
    @departments=Department.all
    @book_date_gteq = Date.today.prev_occurring(:thursday)
    @book_date_lteq = DateTime.now
    if params[:q].present?
      @q = DailyBook.where(department_id: @departments.first.id).ransack(params[:q])
    else
      @q = DailyBook.where(book_date: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,department_id: @departments.second.id).ransack()
    end

    if @q.result.count > 0
      @q.sorts = 'book_date desc' if @q.sorts.empty?
    end
    if params[:q].present?
      @department = params[:q][:department_id]
      @book_date_gteq = params[:q][:book_date_gteq] if params[:q][:book_date_gteq].present?
      @book_date_lteq = params[:q][:book_date_lteq] if params[:q][:book_date_lteq].present?
    end
    @daily_books = @q.result.page(params[:page])
    if params[:submit_pdf].present?
      @pos_setting=PosSetting.first
      if @q.result.count > 0
        @q.sorts = 'book_date desc' if @q.sorts.empty?
      end
      @daily_books=@q.result(distinct: true)
      request.format = 'pdf'
    end
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Day-Out",
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
  def show_nakasi
    @departments=Department.all
    @book_date_gteq = Date.today.prev_occurring(:thursday)
    @book_date_lteq = DateTime.now
    if params[:q].present?
      @q = DailyBook.where(department_id: @departments.first.id).ransack(params[:q])
    else
      @q = DailyBook.where(book_date: @book_date_gteq.to_date.beginning_of_day..@book_date_lteq.to_date.end_of_day,department_id: @departments.third.id).ransack()
    end

    if @q.result.count > 0
      @q.sorts = 'book_date desc' if @q.sorts.empty?
    end
    if params[:q].present?
      @department = params[:q][:department_id]
      @book_date_gteq = params[:q][:book_date_gteq] if params[:q][:book_date_gteq].present?
      @book_date_lteq = params[:q][:book_date_lteq] if params[:q][:book_date_lteq].present?
    end
    @daily_books = @q.result.page(params[:page])
    if params[:submit_pdf].present?
      @pos_setting=PosSetting.first
      if @q.result.count > 0
        @q.sorts = 'book_date desc' if @q.sorts.empty?
      end
      @daily_books=@q.result(distinct: true)
      request.format = 'pdf'
    end
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Day-Out",
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

  # GET /daily_books/new
  def new
    @daily_book = DailyBook.new()
    @departments=Department.all
    @staffs=@departments.first.staffs.with_active.order(:name,:father)
    if @staffs.count>0
      @staffs.each do |staff|
        staff.staff_raw_products.each do |raw|
          @daily_book.salary_details.build(staff_id:staff.id,raw_product_id:raw.raw_product_id)
        end
      end
    end
    @q = DailyBook.where(department_id: @departments.first.id).ransack(params[:q])
    @daily_books = @q.result.page(params[:page])
    if params[:submit_pdf].present?
      @pos_setting=PosSetting.first
      if @q.result.count > 0
        @q.sorts = 'book_date desc' if @q.sorts.empty?
      end
      @daily_books=@q.result(distinct: true)
      request.format = 'pdf'
    end
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Day-Out",
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

  def new_khakar
    @pathera_daily_book = DailyBook.find_by_id(params[:id])
    @departments=Department.all
    @daily_book = DailyBook.new(book_date: params[:book_date],department_id: @departments.second.id)
    @khakar_staffs=@departments.second.staffs.with_active.order(:name,:father)
    @pathera_daily_book.salary_details.each do |salary_detail|
      @daily_book.salary_details.build(staff_pathera_id: salary_detail.staff_id, raw_product_id: salary_detail.raw_product_id, pather_remaning_quanity: salary_detail.pather_remaning_quanity, pather_salary_detail_id: salary_detail.id)
    end
  end
  def stock_new_khakar
    @departments=Department.all
    @daily_book = DailyBook.new(department_id: @departments.second.id)
    @khakar_staffs=@departments.second.staffs.with_active.order(:name,:father)
    @raw_products = RawProduct.all
    #@khakar_staffs.salary_details.each do |salary_detail|
      # @daily_book.salary_details.build(raw_product_id: salary_detail.raw_product_id, pather_remaning_quanity: salary_detail.pather_remaning_quanity, pather_salary_detail_id: salary_detail.id)
    # end
  end

  def new_nakasi
    @raw_products = RawProduct.all
    @products = Product.where.not(raw_product_id:nil)
    @daily_book = DailyBook.new()
    @departments=Department.all
    @staffs=@departments.third.staffs.with_active.order(:name,:father)
    if @staffs.count>0
      @staffs.each do |staff|
        @daily_book.salary_details.build(staff_id:staff.id)
        @products.each do |product|
          @daily_book.salary_details.last.salary_detail_product_quantities.build(staff_id:staff.id,product_id:product.id)
        end
      end
    end
  end

  # GET /daily_books/1/edit
  def edit
    @departments=Department.all
  end

  def edit_khakar
    @departments=Department.all
    @khakar_staffs=Department.second.staffs.with_active
  end

  def edit_pather_khakar_waste
    @pathera_daily_book = DailyBook.find_by_id(params[:id])
    @pathera_daily_book.salary_details.each do |salary_detail|
      salary_detail.pather_khakar_wast = salary_detail.pather_remaning_quanity
      salary_detail.pather_remaning_quanity = 0
      salary_detail.save!
    end
    respond_to do |format|
      format.html { redirect_to khakar_daily_books_path, notice: 'Khakar Daily Waste was successfully created.' }
    end
  end

  def stock_edit_khakar
    @departments=Department.all
    @khakar_staffs=Department.second.staffs.with_active
    @raw_products = RawProduct.all
  end

  def edit_nakasi
    @raw_products = RawProduct.all
    @products = Product.where.not(raw_product_id:nil)
    @departments=Department.all
    @staffs=@departments.third.staffs.with_active
  end

  # POST /daily_books
  # POST /daily_books.json
  def create
    @daily_book = DailyBook.new(daily_book_params)
    @departments=Department.all
    respond_to do |format|
      if @daily_book.save!
        if @daily_book.department_id==@departments.first.id
          staff_debit=@daily_book.salary_details.group(:staff_id).sum(:wage_debit)
          staff_credit=@daily_book.salary_details.group(:staff_id).sum(:amount)
          staff_quantity=@daily_book.salary_details.group(:staff_id,:raw_product_id).sum(:quantity)
          staff_debit.each do |row|
            staff=Staff.find_by_id(row.first)
            staff.wage_debit += row.second
            # staff.balance += staff_credit[row.first].second
            SalaryDetailJob.perform_later(current_user.superAdmin.company_type,row.first)
            staff_quantity.each do |quantity|
              if quantity.first.first==row.first && quantity.last > 0
                staff.raw_product_quantity += quantity.last if quantity.first.last==1
                staff.raw_product_quantity_tile += quantity.last if quantity.first.last==2
              end
            end
            staff.save!
          end
          format.html { redirect_to daily_books_url, notice: 'Daily book was successfully created.' }
          format.json { render :show, status: :created, location: @daily_book }
        elsif  @daily_book.department_id==@departments.second.id

          @daily_book.salary_details.each do |salary_detail|
            if salary_detail.pather_salary_detail_id.present?
              pather_salary_detail = SalaryDetail.find_by_id(salary_detail.pather_salary_detail_id)
              pather_salary_detail.pather_remaning_quanity -= salary_detail.khakar_quanity if salary_detail.khakar_quanity.present? && pather_salary_detail.pather_remaning_quanity.present?
              pather_salary_detail.save!
            else
                brick=RawProduct.find(salary_detail.raw_product_id)
                brick.second_stock -= salary_detail.khakar_quanity
                brick.save!
            end
          end
          staff_debit=@daily_book.salary_details.group(:staff_id).sum(:khakar_debit)
          staff_credit=@daily_book.salary_details.group(:staff_id).sum(:khakar_credit)
          staff_debit.each do |row|
            staff=Staff.find_by_id(row.first)
            staff.wage_debit += row.second.present? ? row.second : 0
            # staff.balance += staff_credit[row.first].second.present? ? staff_credit[row.first].second : 0
            SalaryDetailJob.perform_later(current_user.superAdmin.company_type,row.first)
            staff.save!
          end
          total_stock=@daily_book.salary_details.group(:transaction_location,:raw_product_id).sum(:khakar_remaning)
          total_stock.each do |stock|
            brick=RawProduct.find(stock.first.last)
            if stock.first.first == "bhari"
              brick.first_stock+=stock.last
              brick.save!
            elsif stock.first.first == "stock"
              brick.second_stock+=stock.last
              brick.save!
            elsif stock.first.first == "chapa"
              brick.third_stock+=stock.last
              brick.save!
            end
          end
          format.html { redirect_to khakar_daily_books_path, notice: 'Khakar Daily book was successfully created.' }
          format.json { render :show, status: :created, location: @daily_book }
        elsif @daily_book.department_id==@departments.third.id
          staff_debit=@daily_book.salary_details.group(:staff_id).sum(:wage_debit)
          staff_credit=@daily_book.salary_details.group(:staff_id).sum(:amount)
          staff_debit.each do |row|
            Staff.find_by_id(row.first).increment!(:wage_debit,row.second)
            # Staff.find_by_id(row.first).increment!(:balance,staff_credit[row.first].second)
            SalaryDetailJob.perform_later(current_user.superAdmin.company_type,row.first)
          end
          Product.where(pst:1).update_all('stock=stock+'+@daily_book.brick_rohra.to_s) if @daily_book.brick_rohra.present?
          Product.where(qst:1).update_all('stock=stock+'+@daily_book.tile_rohra.to_s) if @daily_book.tile_rohra.present?
          product_quantities = product_quantity_function(@daily_book.id)
          RawProduct.first.decrement!(:nakasi_stock,@daily_book.brick_rohra)
          RawProduct.last.decrement!(:nakasi_stock,@daily_book.tile_rohra)
          product_quantities.each do |product_quantity|
            if product_quantity.last.to_i>0
              product = Product.find_by_id(product_quantity.first)
              if product.raw_product_id.present?
                product.raw_product.decrement!(:nakasi_stock,product_quantity.last.to_i)
              end
              product.increment!(:stock,product_quantity.last.to_i)
            end
          end
          format.html { redirect_to nakasi_daily_books_path, notice: 'Nakasi Daily book was successfully created.' }
          format.json { render :show, status: :created, location: @daily_book }
        else
          format.html { redirect_to nakasi_daily_books_path, notice: 'Daily book was successfully created.' }
          format.json { render :show, status: :created, location: @daily_book }
        end
      else
        format.html { render :new }
        format.json { render json: @daily_book.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /daily_books/1
  # PATCH/PUT /daily_books/1.json
  def update
    @departments=Department.all
    @raw_products=RawProduct.all
    respond_to do |format|
      if @daily_book.department_id==@departments.first.id #Pather Update
        staff=daily_book_params[:salary_details_attributes]['0'][:staff_id]
        staff_debit=0
        staff_credit=0
        brick=0
        tile=0
        staff_raw_product_quantity=0
        staffs=Hash.new
        staff_raw_product_quantity=Hash.new
        daily_book_params[:salary_details_attributes].each do |salary|
          if salary[1][:staff_id] == staff
            staff_debit += salary[1][:wage_debit].to_f
            staff_credit += salary[1][:amount].to_f
            brick = salary[1][:quantity].to_f if salary[1][:raw_product_id] == @raw_products.first.id.to_s
            tile = salary[1][:quantity].to_f if salary[1][:raw_product_id] == @raw_products.last.id.to_s
            staff_raw_product_quantity[staff] = [ brick, tile ]
            staffs[staff]=[ staff_debit, staff_credit ]
          else
            staff=salary[1][:staff_id]
            staff_debit=salary[1][:wage_debit].to_f
            staff_credit=salary[1][:amount].to_f
            brick=0
            tile=0
            staffs[staff]=[ staff_debit, staff_credit ]
          end
        end
        staff_debit=@daily_book.salary_details.group(:staff_id).sum(:wage_debit)
        staff_credit=@daily_book.salary_details.group(:staff_id).sum(:amount)
        staff_quantity=@daily_book.salary_details.where(raw_product_id: 1).group(:staff_id).sum(:quantity)
        staff_quantity_tile=@daily_book.salary_details.where(raw_product_id: 2).group(:staff_id).sum(:quantity)

        staff_debit.each do |row|
          staff=Staff.find_by_id(row.first)
          if staffs[row.first.to_s].present?
            staff.wage_debit += (staffs[row.first.to_s].first.to_f-row.second.to_f)
            # staff.balance += (staffs[row.first.to_s].second.to_f-staff_credit[row.first].second.to_f)
            SalaryDetailJob.perform_later(current_user.superAdmin.company_type,row.first)
            if staff_raw_product_quantity[row.first.to_s].present?
              staff_quantity_second= staff_quantity[row.first].present? ? staff_quantity[row.first].second : 0
              staff.raw_product_quantity += (staff_raw_product_quantity[row.first.to_s].first-staff_quantity_second)
              staff_raw_product_quantity_second=0
              staff_quantity_tile_second=0
              staff_raw_product_quantity_second=staff_raw_product_quantity[row.first.to_s].second
              staff_quantity_tile_second=staff_quantity_tile[row.first].second if staff_quantity_tile[row.first].present?
              staff.raw_product_quantity_tile += (staff_raw_product_quantity_second-staff_quantity_tile_second)
            end
            staff.save!
          else
          end
        end
      elsif @daily_book.department_id==@departments.second.id #Khakar Update
        staff=daily_book_params[:salary_details_attributes]['0'][:staff_id]
        staff_debit=0
        staff_credit=0
        staff_quantity=0
        staffs=Hash.new
        staff_khakar_quantity=Hash.new
        daily_book_params[:salary_details_attributes].each do |salary|
          staff_khakar_quantity[salary[1][:pather_salary_detail_id]]=salary[1][:khakar_quanity].to_f
          if salary[1][:staff_id] == staff
            staff_debit += salary[1][:khakar_debit].to_f
            staff_credit += salary[1][:khakar_credit].to_f
            staffs[staff]=[ staff_debit, staff_credit ]
          else
            staff=salary[1][:staff_id]
            staff_debit=0
            staff_credit=0
          end
        end
        @daily_book.salary_details.each do |salary_detail|
          pather_salary_detail = SalaryDetail.find_by_id(salary_detail.pather_salary_detail_id)
          if pather_salary_detail.present?
            pather_salary_detail.pather_remaning_quanity += salary_detail.khakar_quanity - staff_khakar_quantity[salary_detail.pather_salary_detail_id.to_s] if salary_detail.khakar_quanity.present? && pather_salary_detail.pather_remaning_quanity.present?
            pather_salary_detail.save!
          end
        end

        staff_debit=@daily_book.salary_details.group(:staff_id).sum(:khakar_debit)
        staff_credit=@daily_book.salary_details.group(:staff_id).sum(:khakar_credit)
        staff_debit.each do |row|
          staff=Staff.find_by_id(row.first)
          if staffs[row.first.to_s].present?
            staff.wage_debit += (staffs[row.first.to_s].first-row.second)
            # staff.balance += (staffs[row.first.to_s].second-staff_credit[row.first].second)
            SalaryDetailJob.perform_later(current_user.superAdmin.company_type,row.first)
            staff.save!
          end
        end
        pre_total_stock=@daily_book.salary_details.group(:transaction_location,:raw_product_id).sum(:khakar_remaning)
      elsif @daily_book.department_id==@departments.third.id #Nakasi Update
        staff=daily_book_params[:salary_details_attributes]['0'][:staff_id]
        staff_debit=0
        staff_credit=0
        staffs=Hash.new
        daily_book_params[:salary_details_attributes].each do |salary|
          if salary[1][:staff_id] == staff
            staff_debit += salary[1][:wage_debit].to_f
            staff_credit += salary[1][:amount].to_f
            staffs[staff]=[ staff_debit, staff_credit ]
          else
            staff=salary[1][:staff_id]
            staff_debit=0
            staff_credit=0
          end
        end
        staff_debit=@daily_book.salary_details.group(:staff_id).sum(:wage_debit)
        staff_credit=@daily_book.salary_details.group(:staff_id).sum(:amount)
        staff_debit.each do |row|
          staff=Staff.find_by_id(row.first)
          if staffs[row.first.to_s].present?
            staff.wage_debit += (staffs[row.first.to_s].first-row.second)
            # staff.balance += (staffs[row.first.to_s].second-staff_credit[row.first].second)
            SalaryDetailJob.perform_later(current_user.superAdmin.company_type,row.first)
            staff.save!
          end
        end
        pre_product_quantities = product_quantity_function(@daily_book.id)
      end
      pre_daily_book_brick_rohra = @daily_book.brick_rohra.to_i
      pre_daily_book_tile_rohra = @daily_book.tile_rohra.to_i

      if @daily_book.update(daily_book_params)
        if @daily_book.department_id == @departments.first.id
          @daily_book.salary_details.each do | salary|
            SalaryDetailJob.perform_later(current_user.superAdmin.company_type,salary.staff_id) if salary.quantity.to_i > 0
            daily = SalaryDetail.where(pather_salary_detail_id:salary)
            if daily.present?
              daily.each do |daily|
                salary.pather_remaning_quanity=salary.pather_remaning_quanity-daily.khakar_quanity
                salary.save!
              end
            end
          end
          format.html { redirect_to daily_books_url, notice: 'Pather Daily book was successfully updated.' }
          format.json { render :show, status: :ok, location: @daily_book }
        elsif @daily_book.department_id==@departments.second.id
          total_stock=@daily_book.salary_details.group(:transaction_location,:raw_product_id).sum(:khakar_remaning)
          total_stock.each do |stock|
            brick = nil
            brick=RawProduct.find(stock.first.last)
            if stock.first.first == "bhari"  && brick.id == stock.first.last
              brick.first_stock+=stock.last-pre_total_stock[[stock.first.first, brick.id]]
              brick.save!
            elsif stock.first.first == "stock"  && brick.id == stock.first.last
              brick.second_stock+=stock.last-pre_total_stock[[stock.first.first, brick.id]]
              brick.save!
            elsif stock.first.first == "chapa" && brick.id == stock.first.last
              brick.third_stock+=stock.last-pre_total_stock[[stock.first.first, brick.id]]
              brick.save!
            end
          end
          format.html { redirect_to khakar_daily_books_url, notice: 'khakar Daily book was successfully updated.' }
          format.json { render :show, status: :ok, location: @daily_book }
        elsif @daily_book.department_id==@departments.third.id
          staff_debit=@daily_book.salary_details.group(:staff_id).sum(:wage_debit)
          staff_credit=@daily_book.salary_details.group(:staff_id).sum(:amount)
          staff_debit.each do |row|
            Staff.find_by_id(row.first).increment!(:wage_debit,row.second)
            # Staff.find_by_id(row.first).increment!(:balance,staff_credit[row.first].second)
            SalaryDetailJob.perform_later(current_user.superAdmin.company_type,row.first)
          end
          product_quantities = product_quantity_function(@daily_book.id)
          RawProduct.first.decrement!(:nakasi_stock,(@daily_book.brick_rohra.to_i-pre_daily_book_brick_rohra.to_i))
          RawProduct.last.decrement!(:nakasi_stock,(@daily_book.tile_rohra.to_i-pre_daily_book_tile_rohra.to_i))
          Product.where(pst:1).update_all('stock=stock+'+(@daily_book.brick_rohra.to_i-pre_daily_book_brick_rohra.to_i).to_s) if @daily_book.brick_rohra.present?
          Product.where(qst:1).update_all('stock=stock+'+(@daily_book.tile_rohra.to_i-pre_daily_book_tile_rohra.to_i).to_s) if @daily_book.tile_rohra.present?
          product_quantities.each do |product_quantity|
            if product_quantity.last.to_i>0
              product = Product.find_by_id(product_quantity.first)
              if product.raw_product_id.present?
                product.raw_product.decrement!(:nakasi_stock,(product_quantity.last.to_i-pre_product_quantities[product_quantity.first].to_i))
              end
              product.increment!(:stock,(product_quantity.last.to_i-pre_product_quantities[product_quantity.first].to_i))
            end
          end
          format.html { redirect_to nakasi_daily_books_path, notice: 'Nakasi Daily book was successfully updated.' }
          format.json { render :show, status: :ok, location: @daily_book }
        else
          format.html { redirect_to nakasi_daily_books_path, notice: 'Daily book was successfully updated.' }
          format.json { render :show, status: :ok, location: @daily_book }
        end
      else
        format.html { render :edit }
        format.json { render json: @daily_book.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /daily_books/1
  # DELETE /daily_books/1.json
  def destroy
    @departments=Department.all
    if @daily_book.department_id==@departments.first.id
      staff_debit=@daily_book.salary_details.group(:staff_id).sum(:wage_debit)
      staff_credit=@daily_book.salary_details.group(:staff_id).sum(:amount)
      staff_quantity=@daily_book.salary_details.where(raw_product_id: 1).group(:staff_id).sum(:quantity)
      staff_quantity_tile=@daily_book.salary_details.where(raw_product_id: 2).group(:staff_id).sum(:quantity)
      staff_debit.each do |row|
        staff=Staff.find_by_id(row.first)
        staff.wage_debit -= row.second.to_f
        staff.balance -= staff_credit[row.first].second
        total_staff_quantity=0
        total_staff_quantity_tile=0
        total_staff_quantity=staff_quantity[row.first].second if staff_quantity[row.first].present?
        total_staff_quantity_tile=staff_quantity_tile[row.first].second if staff_quantity_tile[row.first].present?
        staff.raw_product_quantity -= total_staff_quantity
        staff.raw_product_quantity_tile -= total_staff_quantity_tile
        staff.save!
      end
    elsif @daily_book.department_id==@departments.second.id
      @daily_book.salary_details.each do |salary_detail|
        pather_salary_detail = SalaryDetail.find_by_id(salary_detail.pather_salary_detail_id)
        if pather_salary_detail.present?
          pather_salary_detail.pather_remaning_quanity += salary_detail.khakar_quanity if salary_detail.khakar_quanity.present? && pather_salary_detail.pather_remaning_quanity.present?
          pather_salary_detail.save!
        else
          if salary_detail.raw_product_id == 1
            brick=RawProduct.first
            brick.second_stock += salary_detail.khakar_remaning
            brick.save!
          elsif salary_detail.raw_product_id == 2
            tile=RawProduct.second
            tile.second_stock += salary_detail.khakar_remaning
            tile.save!
          end
        end
      end
      staff_debit=@daily_book.salary_details.group(:staff_id).sum(:khakar_debit)
      staff_credit=@daily_book.salary_details.group(:staff_id).sum(:khakar_credit)
      staff_debit.each do |row|
        staff=Staff.find_by_id(row.first)
        staff.wage_debit -= row.second.present? ? row.second : 0
        staff.balance -= staff_credit[row.first].second.present? ? staff_credit[row.first].second : 0
        staff.save!
      end
      total_stock=@daily_book.salary_details.group(:transaction_location,:raw_product_id).sum(:khakar_remaning)
      total_stock.each do |stock|
        if stock.first.first == "bhari" && stock.first.last == 1
          brick=RawProduct.first
          brick.first_stock-=stock.last
          brick.save!
        elsif stock.first.first == "bhari" && stock.first.last == 2
          tile=RawProduct.second
          tile.first_stock-=stock.last
          tile.save!
        elsif stock.first.first == "stock" && stock.first.last == 1
          brick=RawProduct.first
          brick.second_stock-=stock.last
          brick.save!
        elsif stock.first.first == "stock" && stock.first.last == 2
          tile=RawProduct.second
          tile.second_stock-=stock.last
          tile.save!
        elsif stock.first.first == "chapa" && stock.first.last == 1
          brick=RawProduct.first
          brick.third_stock-=stock.last
          brick.save!
        elsif stock.first.first == "chapa" && stock.first.last == 2
          tile=RawProduct.second
          tile.third_stock-=stock.last
          tile.save!
        end
      end
    elsif @daily_book.department_id==@departments.third.id
      staff_debit=@daily_book.salary_details.group(:staff_id).sum(:wage_debit)
      staff_credit=@daily_book.salary_details.group(:staff_id).sum(:amount)
      product_quantities = product_quantity_function(@daily_book.id)
      RawProduct.first.increment!(:nakasi_stock,@daily_book.brick_rohra.to_i)
      RawProduct.last.increment!(:nakasi_stock,@daily_book.tile_rohra.to_i)
      product_quantities.each do |product_quantity|
        if product_quantity.last.to_i>0
          product = Product.find_by_id(product_quantity.first)
          if product.raw_product_id.present?
            product.raw_product.increment!(:nakasi_stock,product_quantity.last.to_i)
          end
          product.decrement!(:stock,product_quantity.last.to_i)
        end
      end

      @daily_book.salary_details.each do |salary_detail|
        salary_detail.salary_detail_product_quantities.delete_all
        salary_detail.staff_ledger_book.destroy if salary_detail.staff_ledger_book.present?
      end
      staff_debit.each do |row|
        staff=Staff.find_by_id(row.first)
        staff.wage_debit -= row.second
        staff.balance -= staff_credit[row.first].second
        staff.save!
      end
    end
    @daily_book.destroy!
    respond_to do |format|
      if @daily_book.department_id==@departments.first.id
        format.html { redirect_to daily_books_url, notice: 'Daily book was successfully updated.' }
      elsif @daily_book.department_id==@departments.second.id
        format.html { redirect_to khakar_daily_books_url, notice: 'khakar Daily book was successfully updated.' }
      elsif @daily_book.department_id==@departments.third.id
        format.html { redirect_to nakasi_daily_books_path, notice: 'Nakasi Daily book was successfully updated.' }
      else
        format.html { redirect_to daily_books_url, notice: 'Daily book was successfully destroyed.' }
      end
      format.json { render :show, status: :ok, location: @daily_book }
      format.js   { render :layout => false }
    end
  end

  private
    def product_quantity_function(daily_book)
      product_quantities = DailyBook.joins(salary_details: :salary_detail_product_quantities).where(id: daily_book).group('salary_detail_product_quantities.product_id').sum('salary_detail_product_quantities.quantity')
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_daily_book
      @daily_book = DailyBook.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def daily_book_params
      params.require(:daily_book).permit(
        :book_date,
        :total_paid,
        :total_remaining,
        :department_id,
        :comment,
        :brick_rohra,
        :tile_rohra,
        :created_at,
        :salary_details_attributes =>
        [
          :id,
          :daily_book_id,
          :staff_id,
          :amount,
          :remarks,
          :comment,
          :wage_rate,
          :quantity,
          :status,
          :extra,
          :product_id,
          :created_at,
          :raw_product_id,
          :raw_quantity,
          :raw_wage_rate,
          :gift_rate,
          :coverge_rate,
          :wage_debit,
          :gift_pay,
          :coverge_pay,
          :staff_pathera_id,
          :khakar_quanity,
          :khakar_remaning,
          :khakar_wast,
          :transaction_location,
          :khakar_debit,
          :khakar_credit,
          :pather_remaning_quanity,
          :pather_salary_detail_id,
          :created_at,
          :_destroy,
          salary_detail_product_quantities_attributes:
          [
            :id,
            :staff_id,
            :product_id,
            :quantity,
            :_destroy
          ]
        ]
      )
    end
end
