class StaffLedgerBooksController < ApplicationController
  before_action :check_access
  before_action :set_staff_ledger_book, only: %i[show edit update destroy]
  skip_before_action :authenticate_user!, only: [:index]

  # GET /staff_ledger_books
  # GET /staff_ledger_books.json
  def index
    @pos_setting = PosSetting.last
    @departments = Department.all
    @created_at_gteq = Date.today.prev_occurring(:thursday)
    @created_at_lteq = DateTime.now
    if params[:q].present?
      @staff_id = params[:q][:staff_id_eq]
      @comment = params[:q][:comment]
      @created_at_gteq = params[:q][:created_at_gteq]
      @created_at_lteq = params[:q][:created_at_lteq]
      if params[:q][:created_at_lteq].present?
        params[:q][:created_at_lteq] =
          params[:q][:created_at_lteq].to_date.end_of_day
      end
    end
    if params[:q].present?
      @q = StaffLedgerBook.joins(:staff).where('credit>0 or debit>0 or credit<0 or debit<0').ransack(params[:q])
    else
      @q = StaffLedgerBook.joins(:staff).where('credit>0 or debit>0 or credit<0 or debit<0').where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).ransack
    end
    @staff = Staff.all
    @debit = @q.result.sum(:debit)
    @credit = @q.result.sum(:credit)
    if @pos_setting.sys_type =="HousingScheme"
      staff_list = @q.result.order('staff_ledger_books.created_at desc')
    else
      staff_list = @q.result.order('staffs.name asc', 'staff_ledger_books.created_at desc')
    end
    @quantity = StaffLedgerBook.joins(:staff,
                                      :salary_detail).ransack(params[:q]).result.sum(:quantity) + StaffLedgerBook.joins(:staff,
                                                                                                                        :salary_detail).ransack(params[:q]).result.sum(:khakar_remaning)

    @options_for_select = StaffLedgerBook.all
    @custom_pagination = params[:limit].present? ? params[:limit] : 25
    @custom_pagination = @pos_setting.custom_pagination['staff_ledger_books'] if @pos_setting&.custom_pagination.present? && @pos_setting&.custom_pagination['staff_ledger_books'].present?
    @staff_ledger_books = staff_list.page(params[:page]).per(@custom_pagination)

    if params.dig(:q, :staff_id_eq).present? && params.dig(:q, :created_at_gteq).present? && @staff_ledger_books.blank?
      st_id = params[:q][:staff_id_eq]
      st_date = params[:q][:created_at_gteq]
      staff_led = StaffLedgerBook.joins(:staff).where('credit>0 or debit>0 or credit<0 or debit<0')
      @total_b = staff_led.where('staff_ledger_books.created_at < ? AND staff_ledger_books.staff_id = ?', st_date, st_id).order('staff_ledger_books.created_at asc').last&.balance.to_f
    end
    if params[:staff_ledger_book_asc_op].present?
      @staff_ledger_books = @q.result.reorder('created_at asc', 'id asc')
      print_pdf("ASC-OP-StaffLedgerBook -" + @created_at_gteq.to_s + ' to ' + @created_at_lteq.to_s, 'pdf.html', 'A4')
    elsif params[:staff_ledger_book_desc_op]
      @staff_ledger_books = @q.result.reorder('created_at desc', 'id desc')
      print_pdf("DESC-OP-StaffLedgerBook -" + @created_at_gteq.to_s + ' to ' + @created_at_lteq.to_s, 'pdf.html', 'A4')
    end
    pdfName = '[' + StaffLedgerBook.where(id: staff_list.ids).joins(:staff).pluck('name').uniq.join(' ') + ']'
    if params[:bulk].present?
      @staff_ledger_books_pdf_debit = @q.result.group(:name).sum(:debit)
      @staff_ledger_books_pdf_credit = @q.result.group(:name).sum(:credit)
      @staff_ledger_books_pdf_total_debit = @q.result.sum(:debit)
      @staff_ledger_books_pdf_total_credit = @q.result.sum(:credit)
      request.format = 'pdf'
      respond_to do |format|
        format.html
        format.pdf do
          render pdf: "#{pdfName}-StaffLedgerBook -" + @created_at_gteq.to_s + ' to ' + @created_at_lteq.to_s,
                 layout: 'pdf.html',
                 page_size: 'A4',
                 margin_top: '0',
                 margin_right: '0',
                 margin_bottom: '0',
                 margin_left: '0',
                 footer: { # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
                   right: '[page] of [topage]'
                 },
                 encoding: 'UTF-8',
                 show_as_html: false
        end
      end
    end
    if params[:submit_pdf_staff_with_desc].present? or params[:desc_email].present?
      @staff_ledger_books_pdf = @q.result.order('staffs.name asc', 'staff_ledger_books.created_at desc')
      if params[:desc_email]
        @pdf_index = render_to_string(pdf: 'desc - staff ledger book', template: 'staff_ledger_books/index.pdf.erb',
                                      filename: 'desc - staff leger book')
      else
        request.format = 'pdf'
        respond_to do |format|
          format.html
          format.pdf do
            render pdf: "#{pdfName}-StaffLedgerBook -" + @created_at_gteq.to_s + ' to ' + @created_at_lteq.to_s,
                   layout: 'pdf.html',
                   page_size: 'A4',
                   margin_top: '0',
                   margin_right: '0',
                   margin_bottom: '0',
                   margin_left: '0',
                   footer: {             # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
                     right: '[page] of [topage]'
                   },
                   encoding: 'UTF-8',
                   show_as_html: false
          end
        end
      end
    end
    if params[:submit_pdf_staff_with_asc].present? or params[:asc_email].present?
      @staff_ledger_books_pdf = @q.result.order('staffs.name asc', 'staff_ledger_books.created_at asc')
      if params[:asc_email]
        @pdf_index = render_to_string(pdf: 'Asc - staff ledger book', template: 'staff_ledger_books/index.pdf.erb',
                                      filename: 'Asc - staff leger book')
      else
        request.format = 'pdf'
        respond_to do |format|
          format.html
          format.pdf do
            render pdf: "#{pdfName}-StaffLedgerBook -" + @created_at_gteq.to_s + ' to ' + @created_at_lteq.to_s,
                   layout: 'pdf.html',
                   page_size: 'A4',
                   margin_top: '0',
                   margin_right: '0',
                   margin_bottom: '0',
                   margin_left: '0',
                   footer: {             # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
                     right: '[page] of [topage]'
                   },
                   encoding: 'UTF-8',
                   show_as_html: false
          end
        end
      end
    end

    if params[:desc_email].present? or params[:asc_email].present? and @q.result.count > 0
      @pos_setting = PosSetting.first
      subject = "#{@pos_setting.display_name} - staff lager books"
      email = current_user.superAdmin.email_to.present? ? current_user.superAdmin.email_to : 'info@munshionclick.com'
      pdf = [[@pdf_index, 'staff_ledger_books']]
      ReportMailer.new_report_email(pdf, subject, email, '').deliver
      redirect_to staff_ledger_books_path
    end

    return unless params[:csv].present?

    csv_file_of_ledger
  end

  # GET /staff_ledger_books/1
  # GET /staff_ledger_books/1.json
  def show; end

  # GET /staff_ledger_books/new
  def new
    @staff_ledger_book = StaffLedgerBook.new
    @staffs_list = Staff.all
  end

  # GET /staff_ledger_books/1/edit
  def edit
    @staffs_list = Staff.all
  end

  # POST /staff_ledger_books
  # POST /staff_ledger_books.json
  def create
    @balance = StaffLedgerBook.where(staff_id: staff_ledger_book_params[:staff_id]).sum(:credit).to_f - StaffLedgerBook.where(staff_id: staff_ledger_book_params[:staff_id]).sum(:debit).to_f
    @balance = (@balance.to_i + staff_ledger_book_params[:credit].to_i) - staff_ledger_book_params[:debit].to_i
    @staff_ledger_book = StaffLedgerBook.new(staff_ledger_book_params)
    @staff_ledger_book.balance = @balance
    @staff_ledger_book.comment = staff_ledger_book_params[:comment] + ' || ' + staff_ledger_book_params['created_at(3i)'] + '/' + staff_ledger_book_params['created_at(2i)'] + '/' + staff_ledger_book_params['created_at(1i)']

    if staff_ledger_book_params[:status].present?

      @staff_ledger_book_debit = StaffLedgerBook.new(staff_ledger_book_params)
      @staff_ledger_book_debit.staff_id = @staff_ledger_book.status
      @staff_ledger_book_debit.credit = nil
      @staff_ledger_book_debit.debit = @staff_ledger_book.credit
      @staff_ledger_book_debit.comment = @staff_ledger_book_debit.staff.name + ' Transfer ' + @staff_ledger_book.credit.to_s + ' To ' + @staff_ledger_book.staff.name + ' | ' + @staff_ledger_book.comment
      @staff_ledger_book.comment       = @staff_ledger_book.staff.name + ' Received ' + @staff_ledger_book.credit.to_s + ' From ' + @staff_ledger_book_debit.staff.name + ' | ' + @staff_ledger_book.comment
      @balance_debit = StaffLedgerBook.where(staff_id: staff_ledger_book_params[:status]).sum(:credit).to_f - StaffLedgerBook.where(staff_id: staff_ledger_book_params[:status]).sum(:debit).to_f
      @balance_debit = (@balance_debit.to_i - staff_ledger_book_params[:credit].to_i)
      @staff_ledger_book_debit.balance = @balance_debit
      @staff_ledger_book_debit.status  = ''
      @staff_ledger_book_debit.save!
      @staff_ledger_book_debit.staff.update(balance: @balance_debit)
    end

    respond_to do |format|
      if @staff_ledger_book.save!
        @staff_ledger_book.staff.update(balance: @balance)
        format.html { redirect_to get_request_referrer, notice: 'Staff ledger book was successfully created.' }
        format.json { render :show, status: :created, location: @staff_ledger_book }
      else
        format.html { render :new }
        format.json { render json: @staff_ledger_book.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /staff_ledger_books/1
  # PATCH/PUT /staff_ledger_books/1.json
  def update
    respond_to do |format|
      if @staff_ledger_book.update(staff_ledger_book_params)
        balance = StaffLedgerBook.where(staff_id: @staff_ledger_book.staff_id).sum(:credit).to_f - StaffLedgerBook.where(staff_id: @staff_ledger_book.staff_id).sum(:debit).to_f
        staff_ledger_books = StaffLedgerBook.joins(:staff).where(staff_id: @staff_ledger_book.staff_id).where('credit>0 or debit>0').order(
          'staffs.name asc', 'staff_ledger_books.created_at desc'
        )
        staff_ledger_books.each do |lb|
          if lb.balance != balance
            lb.balance = balance.round(2)
            lb.save!
          end
          balance = balance.to_f + (lb.debit.to_f - lb.credit.to_f)
        end
        format.html { redirect_to get_request_referrer, notice: 'Staff ledger book was successfully updated.' }
        format.json { render :show, status: :ok, location: @staff_ledger_book }
      else
        format.html { render :edit }
        format.json { render json: @staff_ledger_book.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /staff_ledger_books/1
  # DELETE /staff_ledger_books/1.json
  def destroy
    @staff_ledger_book.destroy
    respond_to do |format|
      format.html { redirect_to get_request_referrer, notice: 'Staff ledger book was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render layout: false }
    end
  end

  def analytics
    type = params[:type]
    date_limit = case type
                 when 'daily'
                  DateTime.current.all_day
                 when 'weekly'
                   DateTime.current.all_week
                 when 'monthly'
                   DateTime.current.all_month
                 when 'yearly'
                   DateTime.current.all_year
                 else
                   DateTime.current.all_day
                 end

    if params[:q].present?
      if params[:q][:created_at_gteq].present?
        params[:q][:created_at_gteq] =
          params[:q][:created_at_gteq].to_date.beginning_of_day
      end
      if params[:q][:created_at_lteq].present?
        params[:q][:created_at_lteq] =
          params[:q][:created_at_lteq].to_date.end_of_day
      end
     
      @q = StaffLedgerBook.joins(:staff).where('credit>0 or debit>0 or credit<0 or debit<0').ransack(params[:q])
    else
      @q = StaffLedgerBook.joins(:staff).where('credit>0 or debit>0 or credit<0 or debit<0').where(created_at: date_limit).ransack
    end

    @staff_debit = @q.result.group('staffs.name').sum(:debit)
    @staff_credit = @q.result.group('staffs.name').sum(:credit)
    @debit_date = @q.result.group('date(staffs.created_at)').sum(:debit)
    @credit_date = @q.result.group('date(staffs.created_at)').sum(:credit)
  
    respond_to do |format|
      format.js
    end
  end

  def transfer
    @staff_ledger_book = StaffLedgerBook.new
    @staffs = Staff.all
    @accounts = Account.all
  end

  def view_history
    @start_date = Date.today.beginning_of_month
    @end_date = Date.today.end_of_month
    if params[:q].present?
      @start_date = params[:q][:created_at_gteq] if params[:q][:created_at_gteq].present?
      @end_date = params[:q][:created_at_lteq] if params[:q][:created_at_lteq].present?
      @item_id = params[:q][:item_id_eq] if params[:q][:item_id_eq].present?
    end
    @event = %w[create update destroy]
    @q = PaperTrail::Version.where(item_type: 'StaffLedgerBook').order('created_at desc').ransack(params[:q])
    @ledger_book_logs = @q.result.page(params[:page])
    respond_to do |format|
      format.js
    end
  end

  def salary_sheet
    session[:salary_sheet_redirect] = ''
    @pos_setting = PosSetting.last
    @departments = Department.all
    @created_at_gteq = Date.today.beginning_of_month
    @created_at_lteq = DateTime.now
    if params[:q].present?
      @created_at_gteq = params[:q][:created_at_gteq]
      @created_at_lteq = params[:q][:created_at_lteq]
      if params[:q][:created_at_lteq].present?
        params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day
      end
    end
    if params[:q].present?
      @q = StaffLedgerBook.joins(:staff).where('credit>0 or debit>0 or credit<0 or debit<0').ransack(params[:q])
    else
      @q = StaffLedgerBook.joins(:staff).where('credit>0 or debit>0 or credit<0 or debit<0')
                          .where(created_at: @created_at_gteq.to_date.beginning_of_day..@created_at_lteq.to_date.end_of_day).ransack
    end
    @staff = Staff.where(staff_type: 'active')
    @debit = @q.result.sum(:debit)
    @credit = @q.result.sum(:credit)
    staff_list = @q.result.order('staffs.name asc', 'staff_ledger_books.created_at desc')
    @quantity = StaffLedgerBook.joins(:staff,
                                      :salary_detail).ransack(params[:q]).result.sum(:quantity) + StaffLedgerBook.joins(:staff, :salary_detail).ransack(params[:q]).result.sum(:khakar_remaning)

    @options_for_select = StaffLedgerBook.all
    @staff_ledger_books = staff_list.page(params[:page]).per(25)
    @starting_number = 1 + 25 * ([params[:page].to_i, 1].max - 1)

    if params.dig(:q, :staff_id_eq).present? && params.dig(:q, :created_at_gteq).present? && @staff_ledger_books.blank?
      st_id = params[:q][:staff_id_eq]
      st_date = params[:q][:created_at_gteq]
      staff_led = StaffLedgerBook.joins(:staff).where('credit>0 or debit>0 or credit<0 or debit<0')
      @total_b = staff_led.where('staff_ledger_books.created_at < ? AND staff_ledger_books.staff_id = ?', st_date, st_id).order('staff_ledger_books.created_at asc').last&.balance.to_f
    end
    pdfName = '[' + StaffLedgerBook.where(id: staff_list.ids).joins(:staff).pluck('name').uniq.join(' ') + ']'
    if params[:submit_pdf_staff_with_asc].present? or params[:asc_email].present?
      @staff_ledger_books_pdf = @q.result.order('staffs.name asc', 'staff_ledger_books.created_at asc')
      if params[:asc_email]
        @pdf_index = render_to_string(pdf: 'Asc - staff ledger book', template: 'staff_ledger_books/index.pdf.erb',
                                      filename: 'Asc - staff leger book')
      else
        request.format = 'pdf'
        respond_to do |format|
          format.html
          format.pdf do
            render pdf: "#{pdfName}-StaffLedgerBook -" + @created_at_gteq.to_s + ' to ' + @created_at_lteq.to_s,
                   layout: 'pdf.html',
                   page_size: 'A4',
                   margin_top: '0',
                   margin_right: '0',
                   margin_bottom: '0',
                   margin_left: '0',
                   footer: {             # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
                     right: '[page] of [topage]'
                   },
                   encoding: 'UTF-8',
                   show_as_html: false
          end
        end
      end
    end
  end

  def csv_file_of_ledger
    headers = ['ID/P', 'Staff', 'Debit/Benam', 'Credit/Jama', 'Balance', 'Jama/Benam', 'Comment', 'Date']

    rows = @q.result.map do |staff_ledger_book|
      jama_benam = if staff_ledger_book.balance.to_f.positive?
                     'Credit/Jama'
                   elsif staff_ledger_book.balance.to_f.negative?
                     'Debit/Benam'
                   else
                     'Nill'
                   end
      id = "#{staff_ledger_book.id}[#{staff_ledger_book.salary_detail&.payments&.first&.id || staff_ledger_book.salary&.payment&.first&.id}]"
      staff = "#{staff_ledger_book.staff&.code} #{staff_ledger_book.staff&.full_name}"
      debit = staff_ledger_book.debit.to_f.round(2)
      credit = staff_ledger_book.credit.to_f.round(2)
      balance = staff_ledger_book.balance.to_f.round(2)
      comment = "#{staff_ledger_book.comment} #{staff_ledger_book.salary_detail&.comment} #{staff_ledger_book.salary&.comment}"
      created_at = staff_ledger_book.created_at.strftime('%d%b%y , %I:%M')
      [id, staff, debit, credit, balance, jama_benam, comment, created_at]
    end

    csv_data = CSV.generate(headers: true) do |csv|
      csv << headers
      rows.each { |row| csv << row }
    end

    filename = "Staff-ledger-book-#{Date.today}.csv"
    send_data csv_data, filename: filename, disposition: :attachment
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_staff_ledger_book
    @staff_ledger_book = StaffLedgerBook.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def staff_ledger_book_params
    params.require(:staff_ledger_book).permit(:staff_id, :salary_id, :salary_detail_id, :debit, :credit, :balance,
                                              :comment, :created_at, :status)
  end
end
