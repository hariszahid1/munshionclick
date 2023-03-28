class SalaryDetailsController < ApplicationController
  before_action :set_salary_detail, only: [:show, :edit, :update, :destroy]
  before_action :check_access

  # GET /salary_details
  # GET /salary_details.json
  def index
    @pos_setting=PosSetting.first
    @departments=Department.all
    @staffs=Staff.all
    if params[:q].present?
      @department=params[:q][:staff_department_id_eq]
    end
    if params[:q]
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
      @q=SalaryDetail.ransack(params[:q])
    else
      @q=SalaryDetail.ransack(quantity_or_raw_quantity_gt:0,staff_monthly_salary_gt:0)
    end
    if @q.result.count > 0
      @q.sorts = ['id desc', 'created_at desc'] if @q.sorts.empty?
    end
    @options_for_select = SalaryDetail.all
    @custom_pagination = params[:limit].present? ? params[:limit] : 25
    @custom_pagination = @pos_setting.custom_pagination['salary_details'] if @pos_setting&.custom_pagination.present? && @pos_setting&.custom_pagination['salary_details'].present?
    @salary_details = @q.result(distinct: true).page(params[:page]).per(@custom_pagination)
    if params[:submit_pdf].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @salary_details_pdf=@q.result(distinct: true)
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

  def index_batha

    @pos_setting=PosSetting.first
    @departments=Department.all
    @created_at_gteq = Date.today.prev_occurring(:thursday)
    @created_at_lteq = DateTime.now
    if params[:q].present?
      @created_at_gteq = params[:q][:salary_details_created_at_gteq] if params[:q][:salary_details_created_at_gteq].present?
      @created_at_lteq = params[:q][:salary_details_created_at_lteq] if params[:q][:salary_details_created_at_lteq].present?
      @name = params[:q][:id_eq]
      params[:q][:salary_details_created_at_lteq] = params[:q][:salary_details_created_at_lteq].to_date.end_of_day if params[:q][:salary_details_created_at_lteq].present?
      @q=Staff.includes(:salary_details).joins(:salary_details).where(department_id: @departments.first.id).where("salary_details.quantity > ? OR salary_details.raw_quantity > ?", 0, 0).ransack(params[:q])
      @p= Staff.joins(salary_details: :raw_product).where(department_id: @departments.first.id).where("salary_details.quantity > ? OR salary_details.raw_quantity > ?", 0, 0).ransack(params[:q])
    else
      @q=Staff.includes(:salary_details).joins(:salary_details).where(department_id: @departments.first.id).where("salary_details.quantity > ? OR salary_details.raw_quantity > ?", 0, 0).where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).ransack(params[:q])
      @p= Staff.joins(salary_details: :raw_product).where(department_id: @departments.first.id).where("salary_details.quantity > ? OR salary_details.raw_quantity > ?", 0, 0).ransack(params[:q])
    end
    if @q.result.count > 0
      @q.sorts = ['id desc', 'created_at desc'] if @q.sorts.empty?
    end
    @salary_searchs = Staff.where(department_id: @departments.first.id)
    @salary_details = @q.result(distinct: true).page(params[:page]).per(100)
    if params[:submit_pdf_rate].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @salary_details_pdf=@q.result(distinct: true)
      calculate_values_of_data(@salary_details_pdf)
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: 'index_staff_wise_rate',
          layout: 'index_staff_wise_rate.pdf',
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
    elsif params[:submit_pdf_staff_with].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @salary_details_pdf=@q.result(distinct: true)
      calculate_values_of_data(@salary_details_pdf)
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: 'index_staff_wise',
          layout: 'index_staff_wise.pdf',
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
    elsif params[:submit_pdf_work].present? or params[:email].present?

      @salary_details_pdf = @p.result.group('name','raw_products.title').sum(:raw_quantity)
      @salary_queantity_pdf = @p.result.group('name','raw_products.title').sum(:quantity)
      @salary_debit_pdf = @p.result.group('name','raw_products.title').sum('salary_details.wage_debit')
      @salary_khakar_debit_pdf = @p.result.group('name','raw_products.title').sum('salary_details.khakar_debit')
      @salary_gift_pdf = @p.result.group('name','raw_products.title').sum(:gift_pay)
      @salary_cover_pdf = @p.result.group('name','raw_products.title').sum(:coverge_pay)
      @salary_credit_pdf = @p.result.group('name','raw_products.title').sum(:amount)

      @total_debit_pdf = @p.result.sum('salary_details.wage_debit')
      @total_gift_pdf = @p.result.sum(:gift_pay)
      @total_cover_pdf = @p.result.sum(:coverge_pay)
      @total_credit_pdf = @p.result.sum(:amount)
      @total_raw_pdf = @p.result.sum(:raw_quantity)
      @total_quantity_pdf = @p.result.sum(:quantity)

      calculate_values_of_data(@salary_details)
      if params[:email].present?
        @pos_setting=PosSetting.first
        @pdf_index=render_to_string(:pdf => "Pathair work detail",:template => 'layouts/staff_full_work.pdf.erb')
      elsif params[:submit_pdf_work].present?
        request.format = 'pdf'
        respond_to do |format|
          format.html
          format.pdf do
            render pdf: 'staff_full_work',
            layout: 'staff_full_work.pdf',
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
    elsif params[:submit_pdf_staff_without].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @salary_details_pdf=@q.result(distinct: true)
      calculate_values_of_data(@salary_details_pdf)
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: 'index_staff_wise_without_price',
          layout: 'index_staff_wise_without_price.pdf',
          page_size: 'A8',
          margin_top: '0',
          margin_right: '0',
          margin_bottom: '0',
          margin_left: '0',
          encoding: "UTF-8",
          show_as_html: true
        end
      end
    else
      if params[:submit_pdf].present?
        if @q.result.count > 0
          @q.sorts = 'created_at desc' if @q.sorts.empty?
        end
        @salary_details_pdf=@q.result(distinct: true)
        calculate_values_of_data(@salary_details_pdf)
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
      else
        calculate_values_of_data(@salary_details)
      end
    end
    if params[:email].present?
      @pos_setting=PosSetting.first
      subject = "#{@pos_setting.display_name} - Pather-Work-Detail"
      email = current_user.superAdmin.email_to.present? ? current_user.superAdmin.email_to : "info@munshionclick.com"
      pdf=[[@pdf_index,'Pather_Work_Detail']]
      ReportMailer.new_report_email(pdf,subject,email,"").deliver
      return redirect_to pather_salary_details_path
    end

  end

  def index_khakar
    @pos_setting=PosSetting.first
    @departments=Department.all
    @created_at_gteq = Date.today.prev_occurring(:thursday)
    @created_at_lteq = DateTime.now
    if params[:q].present?
      @created_at_gteq = params[:q][:salary_details_created_at_gteq] if params[:q][:salary_details_created_at_gteq].present?
      @created_at_lteq = params[:q][:salary_details_created_at_lteq] if params[:q][:salary_details_created_at_lteq].present?
      @name = params[:q][:id_in]
      params[:q][:salary_details_created_at_lteq] = params[:q][:salary_details_created_at_lteq].to_date.end_of_day if params[:q][:salary_details_created_at_lteq].present?
      params[:q][:staff_id_in]=@name
      @q=Staff.includes(:salary_details).joins(:salary_details).where(department_id: @departments.second.id).where("salary_details.khakar_quanity > ?", 0).ransack(params[:q])
      @p= Staff.joins(salary_details: :raw_product).where(department_id: @departments.second.id).where("salary_details.khakar_quanity > ?", 0).ransack(params[:q])
    else
      @p= Staff.joins(salary_details: :raw_product).where(department_id: @departments.second.id).where("salary_details.khakar_quanity > ?", 0).ransack(params[:q])
      @q=Staff.includes(:salary_details).joins(:salary_details).where(department_id: @departments.second.id).where("salary_details.khakar_quanity > ?", 0).where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).ransack()
    end

    if @name
      params[:q][:id_in]=''
    end
    @f=SalaryDetail.joins(:staff).where('staffs.department_id=?', @departments.second.id).where("khakar_quanity > ?",0).where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).ransack(params[:q])
    @salary_details_f = @f.result(distinct: true)
    .group(:raw_product_id,"DATE(created_at)",:transaction_location,:staff_id,:raw_wage_rate,:wage_rate)
    .order(:staff_id,'Date(created_at)',:raw_product_id)
    .pluck('staff_id','raw_product_id','SUM(khakar_quanity)', 'SUM(khakar_wast)', 'SUM(khakar_remaning)','raw_wage_rate','wage_rate', 'SUM(khakar_debit)', 'SUM(khakar_credit)', 'transaction_location', 'SUM(salary_details.wage_debit)', 'SUM(amount)', 'Date(salary_details.created_at)')
    @salary_details_full =@paginatable_array = Kaminari.paginate_array(@salary_details_f).page(params[:page]).per(1000)
    @salary_detail_total = @f.result(distinct: true)
    .pluck('SUM(khakar_quanity)', 'SUM(khakar_wast)', 'SUM(khakar_remaning)', 'SUM(khakar_debit)', 'SUM(khakar_credit)', 'SUM(salary_details.wage_debit)', 'SUM(amount)')

    if @q.result.count > 0
      @q.sorts = ['id desc', 'created_at desc'] if @q.sorts.empty?
    end
    @salary_searchs = Staff.where('department_id=?', @departments.second.id)
    @salary_details = @q.result(distinct: true).page(params[:page]).per(100)
    if params[:submit_pdf].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @salary_details_pdf=@q.result(distinct: true)
      calculate_values_of_data_khakar(@salary_details_pdf)
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
    elsif params[:submit_pdf_staff_with].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @salary_details_pdf=@q.result(distinct: true)
      calculate_values_of_data_khakar(@salary_details_pdf)
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: 'index_staff_wise',
          layout: 'index_kharkar_wise.pdf',
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
    elsif params[:submit_pdf_staff_without].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @salary_details_pdf = @f.result(distinct: true)
      .group(:raw_product_id,"DATE(created_at)",:transaction_location,:staff_id,:raw_wage_rate,:wage_rate)
      .order(:staff_id,'Date(created_at)',:raw_product_id)
      .pluck('staff_id','raw_product_id','SUM(khakar_quanity)', 'SUM(khakar_wast)', 'SUM(khakar_remaning)','raw_wage_rate','wage_rate', 'SUM(khakar_debit)', 'SUM(khakar_credit)', 'transaction_location', 'SUM(salary_details.wage_debit)', 'SUM(amount)', 'Date(salary_details.created_at)')
      @salary_detail_total = @f.result(distinct: true)
      .pluck('SUM(khakar_quanity)', 'SUM(khakar_wast)', 'SUM(khakar_remaning)', 'SUM(khakar_debit)', 'SUM(khakar_credit)', 'SUM(salary_details.wage_debit)', 'SUM(amount)')
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: 'index_kharkar_wise_without_price',
          layout: 'index_kharkar_wise_without_price.pdf',
          page_size: 'A8',
          margin_top: '0',
          margin_right: '0',
          margin_bottom: '0',
          margin_left: '0',
          encoding: "UTF-8",
          show_as_html: true
        end
      end
    elsif params[:submit_pdf_staff_rate].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @salary_details_pdf=@q.result(distinct: true)
      calculate_values_of_data_khakar(@salary_details_pdf)
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: 'index_kharkar_wise_list',
          layout: 'index_kharkar_wise_list.pdf',
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
    elsif params[:submit_pdf_work].present? or params[:email].present?

      @salary_details_pdf = @p.result.group('name','raw_products.title').sum(:khakar_quanity)
      # @salary_queantity_pdf = @p.result.group('name','raw_products.title').sum(:quantity)

      @total_raw_pdf = @p.result.sum(:khakar_quanity)


      @salary_khakar_debit_pdf = @p.result.group('name','raw_products.title').sum('salary_details.khakar_debit')
      @salary_credit_pdf = @p.result.group('name','raw_products.title').sum('salary_details.khakar_credit')

      @total_debit_pdf = @p.result.sum('salary_details.khakar_debit')
      @total_credit_pdf = @p.result.sum('salary_details.khakar_credit')

      calculate_values_of_data_khakar(@salary_details)
      if params[:email].present?
        @pos_setting=PosSetting.first
        @pdf_index=render_to_string(:pdf => "Khakar work detail",:template => 'layouts/kakhar_full_work.pdf.erb')
      elsif params[:submit_pdf_work].present?
        request.format = 'pdf'
        respond_to do |format|
          format.html
          format.pdf do
            render pdf: 'kakhar_full_work',
            layout: 'kakhar_full_work.pdf',
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
    else
      calculate_values_of_data_khakar(@salary_details)
    end
    if params[:email].present?
      @pos_setting=PosSetting.first
      subject = "#{@pos_setting.display_name} - Khakar-Work-Detail"
      email = current_user.superAdmin.email_to.present? ? current_user.superAdmin.email_to : "info@munshionclick.com"
      pdf=[[@pdf_index,'Khakar_Work_Detail']]
      ReportMailer.new_report_email(pdf,subject,email,"").deliver
      return redirect_to khakar_salary_details_path
    end

  end

  def index_khakar_full
    @pos_setting=PosSetting.first
    @departments=Department.all
    @created_at_gteq = Date.today.prev_occurring(:thursday)
    @created_at_lteq = DateTime.now
    if params[:q].present?
      @created_at_gteq = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @created_at_lteq = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      @name = params[:q][:staff_id_eq]
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?

    end
    @q=SalaryDetail.joins(:staff).where('staffs.department_id=?', @departments.second.id).where("khakar_quanity > ?",0).ransack(params[:q])
    @salary_searchs = Staff.where(department_id: @departments.second.id)
    @salary_details = @q.result(distinct: true)
    .group(:raw_product_id,"DATE(created_at)",:transaction_location,:staff_id,:raw_wage_rate,:wage_rate)
    .order(:staff_id,'Date(created_at)',:raw_product_id)
    .pluck('staff_id','raw_product_id','SUM(khakar_quanity)', 'SUM(khakar_wast)', 'SUM(khakar_remaning)','raw_wage_rate','wage_rate', 'SUM(khakar_debit)', 'SUM(khakar_credit)', 'transaction_location', 'SUM(salary_details.wage_debit)', 'SUM(amount)', 'Date(salary_details.created_at)')
    @salary_details =@paginatable_array = Kaminari.paginate_array(@salary_details).page(params[:page]).per(50)
    @q=SalaryDetail.joins(:staff).where('staffs.department_id=?', @departments.second.id).where("khakar_quanity > ?",0).ransack(params[:q])
    @salary_detail_total = @q.result(distinct: true)
    .pluck('SUM(khakar_quanity)', 'SUM(khakar_wast)', 'SUM(khakar_remaning)', 'SUM(khakar_debit)', 'SUM(khakar_credit)', 'SUM(salary_details.wage_debit)', 'SUM(amount)')

    if params[:submit_pdf].present?
      @salary_details_pdf=@q.result(distinct: true)
      calculate_values_of_data_khakar(@salary_details_pdf)
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
    elsif params[:submit_pdf_staff_with].present?
      @salary_details_pdf=@q.result(distinct: true)
      calculate_values_of_data_khakar(@salary_details_pdf)
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: 'index_staff_wise',
          layout: 'index_kharkar_wise.pdf',
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
    elsif params[:submit_pdf_staff_without].present?
      @salary_details_pdf=@q.result(distinct: true)
      calculate_values_of_data_khakar(@salary_details_pdf)
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: 'index_kharkar_wise_without_price',
          layout: 'index_kharkar_wise_without_price.pdf',
          page_size: 'A8',
          margin_top: '0',
          margin_right: '0',
          margin_bottom: '0',
          margin_left: '0',
          encoding: "UTF-8",
          show_as_html: true
        end
      end
    elsif params[:submit_pdf_staff_rate].present?
      @salary_details_pdf=@q.result(distinct: true)
      calculate_values_of_data_khakar(@salary_details_pdf)
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: 'index_kharkar_wise_list',
          layout: 'index_kharkar_wise_list.pdf',
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

  def index_nakasi
    @pos_setting=PosSetting.first
    @departments=Department.all
    @created_at_gteq = Date.today.prev_occurring(:thursday)
    @created_at_lteq = DateTime.now
    if params[:q].present?
      @created_at_gteq = params[:q][:salary_details_created_at_gteq] if params[:q][:salary_details_created_at_gteq].present?
      @created_at_lteq = params[:q][:salary_details_created_at_lteq] if params[:q][:salary_details_created_at_lteq].present?
      @id = params[:q][:id_eq]
      params[:q][:salary_details_created_at_lteq] = params[:q][:salary_details_created_at_lteq].to_date.end_of_day if params[:q][:salary_details_created_at_lteq].present?
      @q= Staff.includes(:salary_details).joins(:salary_details).where(department_id: @departments.third.id).where("salary_details.quantity > ?",0).where('salary_details.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).ransack(params[:q])
      # @p= Staff.joins(salary_details: :salary_detail_product_quantities).where(department_id: @departments.third.id).where("khakar_quanity > ? or quantity > ?",0, 0).ransack(params[:q])
      @p= Staff.joins(salary_details: [salary_detail_product_quantities: :product]).where('salary_detail_product_quantities.quantity>0').where(department_id: @departments.third.id).ransack(params[:q])
    else
      # @p= Staff.joins(salary_details: :salary_detail_product_quantities).where(department_id: @departments.third.id).where("khakar_quanity > ? or quantity > ?",0, 0).ransack(params[:q])
      @q= Staff.includes(:salary_details).joins(:salary_details).where(department_id: @departments.third.id).where("salary_details.quantity > ?",0).where('salary_details.created_at': @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).ransack(params[:q])
      @p= Staff.joins(salary_details: [salary_detail_product_quantities: :product]).where('salary_detail_product_quantities.quantity>0').where(department_id: @departments.third.id).ransack(params[:q])
    end
    if @q.result.count > 0
      @q.sorts = ['id desc', 'created_at desc'] if @q.sorts.empty?
    end
    @salary_searchs = Staff.where(department_id: @departments.third.id)
    @salary_details = @q.result.page(params[:page]).per(100)
    if params[:submit_pdf].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @salary_details_pdf=@q.result
      calculate_values_of_data_khakar(@salary_details_pdf)
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
    elsif params[:submit_pdf_staff_with].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @salary_details_pdf=@q.result
      calculate_values_of_data_khakar(@salary_details_pdf)
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: 'index_staff_wise',
          layout: 'index_nakasi_wise.pdf',
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
    elsif params[:submit_pdf_staff_without].present?
      if @q.result.count > 0
        @q.sorts = 'created_at asc' if @q.sorts.empty?
      end
      @salary_details_pdf=@q.result
      calculate_values_of_data_khakar(@salary_details_pdf)
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: 'index_staff_wise_rate',
          layout: 'index_nakasi_wise_rate.pdf',
          page_size: 'A8',
          margin_top: '0',
          margin_right: '0',
          margin_bottom: '0',
          margin_left: '0',
          encoding: "UTF-8",
          show_as_html: true
        end
      end
    elsif params[:submit_pdf_staff_list].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @salary_details_pdf=@q.result
      calculate_values_of_data_khakar(@salary_details_pdf)
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: 'index_nakasi_wise_rate_list',
          layout: 'index_nakasi_wise_rate_list.pdf',
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
    elsif params[:submit_pdf_work].present? or params[:email].present?
      @salary_details_pdf = @p.result.group('name','products.title').sum('salary_detail_product_quantities.quantity')
      @salary_debit_pdf = @p.result.group('name','products.title').sum('salary_details.wage_debit')
      @salary_credit_pdf = @p.result.group('name','products.title').sum(:amount)

      @total_debit_pdf = @p.result.sum('salary_detail_product_quantities.quantity*salary_details.raw_wage_rate')
      @total_credit_pdf = @p.result.sum('salary_detail_product_quantities.quantity*salary_details.wage_rate')
      @total_quantity_pdf = @p.result.sum('salary_detail_product_quantities.quantity')
      @salary_details_pdf_full=@p.result.pluck('name','products.title','salary_detail_product_quantities.quantity','wage_rate','raw_wage_rate')


      # @salary_queantity_pdf = @p.result.group('name','raw_products.title').sum(:quantity)

      @total_raw_pdf = @p.result.sum('salary_detail_product_quantities.quantity')
      # @total_quantity_pdf = @p.result.sum(:quantity)
      calculate_values_of_data_khakar(@salary_details)
      if params[:email].present?
        @pos_setting=PosSetting.first
        @pdf_index=render_to_string(:pdf => "Nakasi work detail",:template => 'layouts/nakasi_full_work.pdf.erb')
      elsif params[:submit_pdf_work].present?
        request.format = 'pdf'
        respond_to do |format|
          format.html
          format.pdf do
            render pdf: 'nakasi_full_work',
            layout: 'nakasi_full_work.pdf',
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
    else
      calculate_values_of_data_khakar(@salary_details)
    end

    if params[:email].present?
      @pos_setting=PosSetting.first
      subject = "#{@pos_setting.display_name} - Nakasi-Work-Detail"
      email = current_user.superAdmin.email_to.present? ? current_user.superAdmin.email_to : "info@munshionclick.com"
      pdf=[[@pdf_index,'Nakasi_Work_Detail']]
      ReportMailer.new_report_email(pdf,subject,email,"").deliver
      return redirect_to nakasi_salary_details_path
    end

  end

  def index_vehicle
    @pos_setting=PosSetting.first
    @departments=Department.all
    @created_at_gteq = Date.today.prev_occurring(:thursday)
    @created_at_lteq = DateTime.now
    if params[:q].present?
      @created_at_gteq = params[:q][:salary_details_created_at_gteq] if params[:q][:salary_details_created_at_gteq].present?
      @created_at_lteq = params[:q][:salary_details_created_at_lteq] if params[:q][:salary_details_created_at_lteq].present?
      @name = params[:q][:name_or_father_or_code_cont]
      params[:q][:salary_details_created_at_lteq] = params[:q][:salary_details_created_at_lteq].to_date.end_of_day if params[:q][:salary_details_created_at_lteq].present?
      @q=Staff.includes(:salary_details).joins(:salary_details).where(department_id: @departments.fourth.id).ransack(params[:q])
    else
      @q=Staff.includes(:salary_details).joins(:salary_details).where(department_id: @departments.fourth.id).where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).ransack(params[:q])
    end
    if @q.result.count > 0
      @q.sorts = ['id desc', 'created_at desc'] if @q.sorts.empty?
    end
    @salary_searchs = Staff.where(department_id: @departments.fourth.id)
    @salary_details = @q.result(distinct: true).page(params[:page]).per(100)
    if params[:submit_pdf].present? or params[:email].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @salary_details_pdf=@q.result(distinct: true)
      calculate_values_of_data_khakar(@salary_details_pdf)
      if params[:email].present?
        @pos_setting=PosSetting.first
        @pdf_index=render_to_string(:pdf => "Vehicle work detail",:template => 'salary_details/index_vehicle.pdf.erb')
      elsif params[:submit_pdf].present?
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
    elsif params[:submit_pdf_staff_with].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @salary_details_pdf=@q.result(distinct: true)
      calculate_values_of_data_khakar(@salary_details_pdf)
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: 'index_ vehicle_wise',
          layout: 'index_vehicle_wise.pdf',
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
    elsif params[:submit_pdf_staff_without].present?
      if @q.result.count > 0
        @q.sorts = 'created_at asc' if @q.sorts.empty?
      end
      @salary_details_pdf=@q.result(distinct: true)
      calculate_values_of_data_khakar(@salary_details_pdf)
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: 'index_staff_wise_rate',
          layout: 'index_nakasi_wise_rate.pdf',
          page_size: 'A8',
          margin_top: '0',
          margin_right: '0',
          margin_bottom: '0',
          margin_left: '0',
          encoding: "UTF-8",
          show_as_html: true
        end
      end
    elsif params[:submit_pdf_staff_list].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @salary_details_pdf=@q.result(distinct: true)
      calculate_values_of_data_khakar(@salary_details_pdf)
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: 'index_nakasi_wise_rate_list',
          layout: 'index_nakasi_wise_rate_list.pdf',
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
    else
      calculate_values_of_data_khakar(@salary_details)
    end
    if params[:email].present?
      @pos_setting=PosSetting.first
      subject = "#{@pos_setting.display_name} - Vehicle-Work-Detail"
      email = current_user.superAdmin.email_to.present? ? current_user.superAdmin.email_to : "info@munshionclick.com"
      pdf=[[@pdf_index,'Vehicle_Work_Detail']]
      ReportMailer.new_report_email(pdf,subject,email,"").deliver
      return redirect_to vehicle_salary_details_path
    end

  end

  def calculate_values_of_data_khakar(staff)
    @khakar_quanity=0
    @quantity=0
    @Wast=0
    @amount=0
    @khakar_debit=0
    @after_kat=0
    @debit_rate=0
    @credit_rate=0
    @debit_total=0
    @khakar_credit=0
    @credit_total=0
    @wage_debit=0
    @Wast=0

    @salary_details_total = SalaryDetail.where(staff_id: staff)

    @Wast = @salary_details_total.sum(:khakar_wast)
    @after_kat = @salary_details_total.sum(:khakar_remaning)
    @amount = @salary_details_total.sum(:amount)
    @wage_debit = @salary_details_total.sum(:wage_debit)


    @khakar_quanity = @salary_details_total.sum(:khakar_quanity)
    @khakar_debit= @salary_details_total.sum(:khakar_debit)
    @quantity = @salary_details_total.sum(:quantity)
    @debit_rate = @salary_details_total.sum(:raw_wage_rate)
    @credit_rate = @salary_details_total.sum(:wage_rate)
    @debit_total = @salary_details_total.sum(:khakar_debit)
    @credit_total = @salary_details_total.sum(:khakar_credit)
    @khakar_credit = @salary_details_total.sum(:khakar_credit)
  end

  def calculate_values_of_data(staff)
    @raw_quantity_sum=0
    @quantity_sum=0
    @wast_sum=0
    @raw_wage_rate_sum=0
    @wage_debit_sum=0
    @wage_rate_sum=0
    @amount_sum=0
    @gift_pay_sum=0
    @gift_rate_sum=0
    @coverge_rate_sum=0
    @coverge_pay_sum=0

    @salary_details_total = SalaryDetail.where(staff_id: staff)

    @raw_quantity_sum = @salary_details_total.where.not(raw_product_id:nil).sum(:raw_quantity)
    @quantity_sum = @salary_details_total.where.not(raw_product_id:nil).sum(:quantity)
    @wast_sum =@salary_details_total.sum(:extra)
    @wage_debit_sum =@salary_details_total.sum(:wage_debit)
    @amount_sum =@salary_details_total.sum(:amount)
    @gift_pay_sum =@salary_details_total.sum(:gift_pay)
    @coverge_pay_sum = @salary_details_total.sum(:coverge_pay)
  end

  def edit_bulk
    @pos_setting=PosSetting.first
    @departments=Department.first(3)
    @created_at_gteq = Date.today.prev_occurring(:thursday)
    @created_at_lteq = DateTime.now
    @created_at_gteq = params[:created_at_gteq] if params[:created_at_gteq].present?
    @created_at_lteq = params[:created_at_lteq] if params[:created_at_lteq].present?
    @department = @departments.first.id if @departments.present?
    @department = params[:department_id_eq] if params[:department_id_eq].present?
    if @department.present?
      if @departments.first.id == @department.to_i
        @salary_details = SalaryDetail.joins(:staff).where('staffs.department_id=?',@department).where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:staff_id).sum(:raw_quantity)
      elsif @departments.second.id == @department.to_i
        @salary_details = SalaryDetail.joins(:staff).where('staffs.department_id=?',@department).where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:staff_id).sum(:khakar_remaning)
      elsif @departments.third.id == @department.to_i
        @salary_details = SalaryDetail.joins(:staff).where('staffs.department_id=?',@department).where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:staff_id).sum(:quantity)
      end
    else
      @salary_details = SalaryDetail.joins(:staff).where('staffs.department_id=?',@departments.first.id).where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).group(:staff_id).sum(:raw_quantity)
    end
  end

  def update_bulk
    @departments=Department.first(3)
    @department = params[:department_id_eq] if params[:department_id_eq].present?
    @staff = Staff.active_staff(@department)
    @created_at_gteq = Date.today.prev_occurring(:thursday)
    @created_at_lteq = DateTime.now
    @created_at_gteq=params[:user_created_at_gteq] if params[:user_created_at_gteq].present?
    @created_at_lteq=params[:user_created_at_lteq] if params[:user_created_at_lteq].present?
    if @departments.first.id == @department.to_i
      @staff.each do |staff|
        staff_id = params[:user]['id_'+staff.id.to_s]
        staff_rate = params[:user]['rate_'+staff.id.to_s].to_f/(1000).to_f
        gift_rate = params[:user]['gift_rate_'+staff.id.to_s].to_f/(1000).to_f
        coverge_rate = params[:user]['coverge_rate_'+staff.id.to_s].to_f/(1000).to_f
        staff_wage_debit = params[:user]['wage_debit_'+staff.id.to_s]
        gift_rate_total = params[:user]['gift_rate_total_'+staff.id.to_s]
        coverge_rate_total = params[:user]['coverge_rate_total_'+staff.id.to_s]
        raw_quantity = staff.salary_details.where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:raw_quantity)
        wage_debit = staff.salary_details.where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:wage_debit)

        total_staff_rate=0
        total_gift_rate=0
        total_coverge_rate=0
        if (staff_wage_debit.present? && staff_rate.present?)
          total_staff_rate = (staff_wage_debit.to_f/raw_quantity.to_f) if raw_quantity>0
        end
        if (gift_rate.present?)
          total_gift_rate = (gift_rate_total.to_f/raw_quantity.to_f) if raw_quantity>0
        end
        if (coverge_rate.present?)
          total_coverge_rate = (coverge_rate_total.to_f/raw_quantity.to_f) if raw_quantity.to_f>0
        end
        salary_details = staff.salary_details.where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).where('raw_quantity>0').update_all(['raw_wage_rate=?,gift_rate=?,coverge_rate=?, wage_debit=raw_wage_rate*raw_quantity,  gift_pay=gift_rate*raw_quantity,  coverge_pay=coverge_rate*raw_quantity',total_staff_rate,total_gift_rate,total_coverge_rate])
        staff.update(wage_debit: (staff.wage_debit+(staff_wage_debit.to_i-wage_debit.to_i)).round(-2))
      end
      respond_to do |format|
        format.html { redirect_to daily_books_url, notice: 'Weekly Pay Adjustment was successfully created.' }
      end
    elsif @departments.second.id == @department.to_i
      @staff.each do |staff|
        staff_id = params[:user]['id_'+staff.id.to_s]
        staff_rate = params[:user]['rate_'+staff.id.to_s].to_f/(1000).to_f
        staff_wage_debit = params[:user]['wage_debit_'+staff.id.to_s]
        raw_quantity = staff.salary_details.where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:khakar_remaning)
        wage_debit = staff.salary_details.where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:wage_debit)

        total_staff_rate=0
        if (staff_wage_debit.present? && staff_rate.present?)
          total_staff_rate = (staff_wage_debit.to_f/raw_quantity.to_f) if raw_quantity>0
        end
        salary_details = staff.salary_details.where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).where('khakar_remaning>0').update_all(['raw_wage_rate=?, khakar_debit=raw_wage_rate*khakar_remaning',total_staff_rate])
        staff.update(wage_debit: (staff.wage_debit+(staff_wage_debit.to_i-wage_debit.to_i)).round(-1))
      end
      respond_to do |format|
        format.html { redirect_to khakar_daily_books_path, notice: 'Weekly Pay Adjustment was successfully created.' }
      end
    elsif @departments.third.id == @department.to_i
      @staff.each do |staff|
        staff_id = params[:user]['id_'+staff.id.to_s]
        staff_rate = params[:user]['rate_'+staff.id.to_s].to_f/(1000).to_f
        staff_wage_debit = params[:user]['wage_debit_'+staff.id.to_s]
        raw_quantity = staff.salary_details.where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:quantity)
        wage_debit = staff.salary_details.where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).sum(:wage_debit)
        total_staff_rate=0
        if (staff_wage_debit.present? && staff_rate.present?)
          total_staff_rate = (staff_wage_debit.to_f/raw_quantity.to_f) if raw_quantity>0
        end
        salary_details = staff.salary_details.where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).where('quantity>0').update_all(['raw_wage_rate=?, wage_debit=raw_wage_rate*quantity',total_staff_rate])
        staff.update(wage_debit: (staff.wage_debit+(staff_wage_debit.to_i-wage_debit.to_i)).round(-1))
      end
      respond_to do |format|
        format.html { redirect_to nakasi_daily_books_path, notice: 'Weekly Pay Adjustment was successfully created.' }
      end
    end

  end
  def advance_all
    if params[:salary_sheet].present?
      session[:salary_sheet_redirect] = salary_sheet_staff_ledger_books_path
    end
    @departments = Department.all
    if params[:q].present? || pos_type_batha.blank?
    @q = Staff.ransack(params[:q])
    else
      @q = Staff.ransack(monthly_salary_gt:1)
    end
    if @q.result.count > 0
      @q.sorts = 'name asc' if @q.sorts.empty?
    end
    @staffs=Staff.all
    @staffs_list = @q.result(distinct: true)
    @salary_detail = SalaryDetail.new(comment: 'Payment Credit',quantity:1)
  end

  # GET /salary_details/1
  # GET /salary_details/1.json
  def show
  end

  # GET /salary_details/new
  def new
    @salary_detail = SalaryDetail.new
    @salary_detail.payments.build
    @staffs_list = activated_list("Staff")
    @products=Product.all
    @accounts=Account.all
    @pos_type_batha = pos_type_batha
  end

  # GET /salary_details/1/edit
  def edit
    if params[:salary_sheet].present?
      session[:salary_sheet_redirect] = salary_sheet_staff_ledger_books_path
    end
    @staffs_list = activated_list("Staff")
    @products=Product.all
    @salary_detail.payments.build if @salary_detail.payments.blank?
    @accounts=Account.all
    @pos_type_batha = pos_type_batha
  end

  # POST /salary_details
  # POST /salary_details.json
  def create
    @salary_detail = SalaryDetail.new(salary_detail_params)
    @salary_detail.comment=@salary_detail.payments&.first&.comment if @salary_detail.payments.present?
    if current_user.superAdmin.company_type=="upsi"
      if @salary_detail.staff.staff_department=="Plant 1"
        @staff = Staff.where(staff_department: "Plant 1").where(id:params[:salary_detail][:staff].split(/\s*,\s*/).map(&:to_i))
        count=params[:salary_detail][:staff_count].present? ? params[:salary_detail][:staff_count].to_i+1 : @staff.count+1
        @salary_detail.amount = (@salary_detail.amount/count)
        @staff.each do |staff|
          @salary_details = SalaryDetail.new(salary_detail_params)
          @salary_details.staff_id=staff.id
          @salary_details.status=0
          @salary_details.quantity=0
          @salary_details.amount = @salary_detail.amount
          staff.balance=staff.balance+@salary_detail.amount
          @salary_details.save!
        end
      end
    end
    if @salary_detail.product_id?
      quantity=@salary_detail.quantity.present? ? @salary_detail.quantity : 0
      pack=@salary_detail.status.present? ? @salary_detail.status : 1
      extra=@salary_detail.extra.present? ? @salary_detail.extra : 0
      stock=@salary_detail.product.stock.present? ? @salary_detail.product.stock : 0
      total_stock=((pack*quantity)-extra)+stock
      @salary_detail.product.update(stock: total_stock)
    end
    respond_to do |format|
      if @salary_detail.staff_id?
        @salary_detail.staff.balance.present? ? balance=@salary_detail.amount+@salary_detail.staff.balance : balance=0
        @salary_detail.staff.wage_debit.present? ? wage_debit=@salary_detail.amount+@salary_detail.staff.wage_debit : wage_debit=0
        @salary_detail.staff.update(balance: balance, wage_debit: wage_debit)
        @salary_detail.remarks=balance.to_s
      end
      if @salary_detail.save
        format.html { redirect_to new_salary_detail_path, notice: 'Salary detail was successfully created.' }
        format.json { render :show, status: :created, location: @salary_detail }
        format.js   { }
      else
        @staffs_list = activated_list("Staff")
        @products=Product.all
        format.html { render :new }
        format.json { render json: @salary_detail.errors, status: :unprocessable_entity }
        format.js   { }
      end
    end
  end

  # PATCH/PUT /salary_details/1
  # PATCH/PUT /salary_details/1.json
  def update
    respond_to do |format|
      if @salary_detail.product_id?
        quantity=@salary_detail.quantity.present? ? @salary_detail.quantity : 0
        pack=@salary_detail.status.present? ? @salary_detail.status : 1
        extra=salary_detail_params[:extra].present? ? salary_detail_params[:extra].to_f : 0
        puts "quantity"+quantity.to_s
        puts "pack"+pack.to_s
        puts "extra"+extra.to_s
        stock=@salary_detail.product.stock.present? ? @salary_detail.product.stock : 0
        quantity_was=@salary_detail.quantity_was.present? ? @salary_detail.quantity_was : 0
        pack_was=@salary_detail.status_was.present? ? @salary_detail.status_was : 1
        extra_was=@salary_detail.extra_was.present? ? @salary_detail.extra_was : 0
        puts "stock"+stock.to_s
        puts "quantity_was"+quantity_was.to_s
        puts "pack_was"+pack_was.to_s
        puts "extra_was"+extra_was.to_s
        total_stock=(((pack*quantity)-extra)-((pack_was*quantity_was)-extra_was))+stock
        @salary_detail.product.update(stock: total_stock)
      end

      if @salary_detail.staff_id?
        @salary_detail.staff.balance.present? ? balance=(salary_detail_params[:amount].to_f-@salary_detail.amount)+@salary_detail.staff.balance : balance=0
        @salary_detail.staff.update_column(:balance, balance)
        @salary_detail.update_column(:remarks, balance.to_s)
      end
      if @salary_detail.update(salary_detail_params)
        if session[:salary_sheet_redirect].present?
          format.html { redirect_to session[:salary_sheet_redirect], notice: 'Salary detail was successfully updated.' }
        else
          format.html { redirect_to salary_details_path, notice: 'Salary detail was successfully updated.' }
        end
        format.json { render :show, status: :ok, location: @salary_detail }
      else
        @staffs_list = activated_list("Staff")
        @products=Product.all
        format.html { render :edit }
        format.json { render json: @salary_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /salary_details/1
  # DELETE /salary_details/1.json
  def destroy
    if @salary_detail.staff_id?
      @salary_detail.staff.balance.present? ? balance=@salary_detail.staff.balance-@salary_detail.amount : balance=0
      @salary_detail.staff.update_column(:balance, balance)
    end
    @salary_detail.destroy!
    SalaryDetailJob.perform_later(current_user.superAdmin.company_type,@salary_detail.staff_id)
    respond_to do |format|
      format.html { redirect_to salary_details_url, notice: 'Salary detail was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }
    end
  end

  def salary_department
    @staff=Staff.where(staff_department:'Plant 1')
    @salary_details=Hash.new
    (1..(@staff.count)).each do |i|
      @salary_details[i]=SalaryDetail.new(staff_id: @staff[i])
    end
    puts @salary_details
  end

  def analytics
    type = params[:type]
    case type
    when 'daily'
      date_limit = DateTime.current.all_day
    when 'weekly'
      date_limit = DateTime.current.all_week
    when 'monthly'
      date_limit = DateTime.current.all_month
    when 'yearly'
      date_limit = DateTime.current.all_year
    else
      date_limit = DateTime.current.all_day
    end

    if params[:q].present?
      params[:q][:created_at_gteq] = params[:q][:created_at_gteq].to_date.beginning_of_day if params[:q][:created_at_gteq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day if params[:q][:created_at_lteq].present?
      @q = SalaryDetail.joins(staff: :department).includes(staff: :department).ransack(params[:q])
    else
      @q = SalaryDetail.joins(staff: :department).includes(staff: :department).where(created_at: date_limit).ransack(params[:q])
    end
    @salaries = @q.result.group('staffs.name').sum(:amount)
    @with_department = @q.result.group('departments.title').sum(:amount)
    @salaries_date = @q.result.group("date(salary_details.created_at)").sum(:amount)
    respond_to do |format|
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_salary_detail
      @salary_detail = SalaryDetail.find(params[:id])
    end

    def activated_list(model_name)
      model_name.constantize.where(terminated: false, deleted: false)
    end
    # Only allow a list of trusted parameters through.
    def salary_detail_params
      params.require(:salary_detail).permit(
        :staff_id,
        :wage_rate,
        :quantity,
        :amount,
        :remarks,
        :comment,
        :created_at,
        :updated_at,
        :product_id,
        :status, :extra, :daily_book_id, :raw_product_id, :raw_quantity, :raw_wage_rate, :gift_rate, :coverge_rate, :wage_debit, :gift_pay, :coverge_pay,
        :payments_attributes => [
          :id,
          :salary_detail_id,
          :debit,
          :credit,
          :account_id,
          :comment,
          :_destroy
        ]
       )
    end
end
