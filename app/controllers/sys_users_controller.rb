class SysUsersController < ApplicationController


  before_action :set_sys_user, only: [:show, :edit, :update, :destroy]

  # GET /sys_users
  # GET /sys_users.json
  def index
      @q = SysUser.ransack(params[:q])
      if @q.result.count > 0
        @q.sorts = 'name asc' if @q.sorts.empty?
      end
      if params[:q].present?
        @code = params[:q][:code]
        @cnic = params[:q][:cnic]
        @name = params[:q][:id_eq]
        @user_type = params[:q][:user_type]
        @user_group = params[:q][:user_group_eq]
        @contact = params[:q][:contact]
        @status = params[:q][:status]
        @occupation = params[:q][:occupation]
        @credit_status = params[:q][:credit_status]
        @credit_limit = params[:q][:credit_limit]
        @opening_balance = params[:q][:opening_balance]
      end

      @sys_users = @q.result.page(params[:page])
      @sys_user_balance = @q.result.sum(:balance).to_f.round(2)
      @all_user =SysUser.all
      @user_types=UserType.all
      if params[:submit_pdf_staff_with].present?
        if @q.result.count > 0
          @q.sorts = 'name asc' if @q.sorts.empty?
        end
        @pos_setting=PosSetting.first
        @sys_users=@q.result(distinct: true)
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

  # GET /sys_users/1
  # GET /sys_users/1.json
  def show
    @user_types=UserType.all
    @cities=City.all
    @countries=Country.all
  end

  def payable
    @q = SysUser.where('balance > 0 ').ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = 'name asc' if @q.sorts.empty?
    end
    @sys_users = @q.result(distinct: true)
    @all_user =SysUser.all
    @user_types=UserType.all
    if params[:submit_pdf_staff_with].present?
      if @q.result.count > 0
        @q.sorts = 'name desc' if @q.sorts.empty?
      end
      @sys_users=@q.result(distinct: true)
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

  def receiveable
    @q = SysUser.where('balance < 0 ').ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = 'name asc' if @q.sorts.empty?
    end
    if params[:q].present?
      @code = params[:q][:code]
      @cnic = params[:q][:cnic]
      @name = params[:q][:name_or_code_cont]
      @user_type = params[:q][:user_type]
      @user_group = params[:q][:user_group_eq]
      @contact = params[:q][:contact]
      @status = params[:q][:status]
      @occupation = params[:q][:occupation]
      @credit_status = params[:q][:credit_status]
      @credit_limit = params[:q][:credit_limit]
      @opening_balance = params[:q][:opening_balance]
    end
    @sys_users = @q.result(distinct: true)
    @all_user =SysUser.all
    @user_types=UserType.all
    if params[:submit_pdf_staff_with].present?
      if @q.result.count > 0
        @q.sorts = 'name desc' if @q.sorts.empty?
      end
      @sys_users=@q.result(distinct: true)
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

  def customer
    @sys_user_all = SysUser.where(:user_group=>['Customer'])
    @q = SysUser.where(:user_group=>['Customer']).ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = 'id asc' if @q.sorts.empty?
    end
    if params[:q].present?
      @name = params[:q][:name_or_code_cont]
    end
    @sys_users = @q.result
    @user_types=UserType.all
    if params[:submit_pdf_staff_with].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @sys_users_pdf=@q.result
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

  def supplier
    @sys_user_all = SysUser.where(:user_group=>['Supplier'])
    @q = SysUser.where(:user_group=>['Supplier']).ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = 'id asc' if @q.sorts.empty?
    end
    if params[:q].present?
      @name = params[:q][:name_or_code_cont]
    end
    @sys_users = @q.result
    @user_types=UserType.all
    if params[:submit_pdf_staff_with].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @sys_users_pdf=@q.result
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

  def own
    @sys_user_all = SysUser.where(:user_group=>['Own'])
    @q = SysUser.where(:user_group=>['Own']).ransack(params[:q])
    if @q.result.count > 0
      @q.sorts = 'id asc' if @q.sorts.empty?
    end
    if params[:q].present?
      @name = params[:q][:name_or_code_cont]
    end
    @sys_users = @q.result
    @user_types=UserType.all
    if params[:submit_pdf_staff_with].present?
      if @q.result.count > 0
        @q.sorts = 'created_at desc' if @q.sorts.empty?
      end
      @sys_users_pdf=@q.result
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

  # GET /sys_users/new
  def new
    @user_types=UserType.all
    @sys_user = SysUser.new
    @cities=City.all
    @countries=Country.all
    @sys_user.build_contact
  end

  # GET /sys_users/1/edit
  def edit
    @user_types=UserType.all
    @cities=City.all
    @countries=Country.all
  end

  # POST /sys_users
  # POST /sys_users.json
  def create
    @sys_user = SysUser.new(sys_user_params)

    respond_to do |format|
      if @sys_user.save!
        format.html { redirect_to get_request_referrer, notice: 'Sys user was successfully created.' }
        format.json { render :show, status: :created, location: @sys_user }
      else
        format.html { render :new }
        format.json { render json: @sys_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sys_users/1
  # PATCH/PUT /sys_users/1.json
  def update
    if params[:order_id] && params[:commit]
      Order.find(params[:order_id]).remarks.new(body:sys_user_params[:name],message: current_user.name+" - "+current_user.user_name, comment: @sys_user.name,remark_type:"Transfer").save!
    end
    respond_to do |format|
      if @sys_user.update!(sys_user_params)
        format.html { redirect_to get_request_referrer, notice: 'Sys user was successfully updated.' }
        format.json { render :show, status: :ok, location: @sys_user }
      else
        format.html { render :edit }
        format.json { render json: @sys_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sys_users/1
  # DELETE /sys_users/1.json
  def destroy
    @sys_user.destroy!
    respond_to do |format|
      format.html { redirect_to get_request_referrer, notice: 'Sys user was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }
    end
  end


  # GET /sys_users/1
  # GET /sys_users/1.json
  def sys_user_balance
    sys_user = SysUser.find(params[:sys_user_id])
    respond_to do |format|
      format.json { render json: {status: 'success', balance: sys_user.balance}, status: :ok}
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sys_user
      @sys_user = SysUser.find(params[:id])
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def sys_user_params
      params.require(:sys_user).permit(
        :code,
        :cnic,
        :name,
        :user_type_id,
        :user_group,
        :status,
        :occupation,
        :credit_status,
        :credit_limit,
        :opening_balance,
        :profile_image,
        :balance,
        :gst,
        :ntn,
        :father,
        :nom_name,
        :nom_father,
        :nom_cnic,
        :nom_relation,
        :contact_attributes => [
          :id,
          :address,
          :home,
          :office,
          :mobile,
          :fax,
          :email,
          :comment,
          :status,
          :city_id,
          :country_id,
          :sys_user_id,
          :permanent_address
          ]
        )
    end
end
