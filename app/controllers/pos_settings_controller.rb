class PosSettingsController < ApplicationController
  before_action :set_pos_setting, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  # GET /pos_settings
  # GET /pos_settings.json
  def index
    @pos_settings = PosSetting.all
    @account =Account.all

  end

  # GET /pos_settings/1
  # GET /pos_settings/1.json
  def show
    @account =Account.all

  end

  # GET /pos_settings/new
  def new
    @pos_setting = PosSetting.new
    @account =Account.all
  end

  # GET /pos_settings/1/edit
  def edit
    @account =Account.all

  end

  # POST /pos_settings
  # POST /pos_settings.json
  def create
    pos_setting_params[:sms_templates] = eval(pos_setting_params[:sms_templates])
    pos_setting_params[:qr_links] = eval(pos_setting_params[:qr_links])
    pos_setting_params[:extra_settings] = eval(pos_setting_params[:extra_settings])
    @pos_setting = PosSetting.new(pos_setting_params)

    respond_to do |format|
      if @pos_setting.save
        format.js
        format.html { redirect_to @pos_setting, notice: 'General Setting was successfully created.' }
        format.json { render :show, status: :created, location: @pos_setting }
      else
        format.html { render :new }
        format.json { render json: @pos_setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pos_settings/1
  # PATCH/PUT /pos_settings/1.json
  def update
    respond_to do |format|
      pos_setting_params[:sms_templates] = eval(pos_setting_params[:sms_templates])
      pos_setting_params[:qr_links] = eval(pos_setting_params[:qr_links])
      pos_setting_params[:extra_settings] = eval(pos_setting_params[:extra_settings])
      if @pos_setting.update(pos_setting_params)
        @pos_setting.update(sms_templates: eval(pos_setting_params[:sms_templates]))
        @pos_setting.update(qr_links: eval(pos_setting_params[:qr_links]))
        @pos_setting.update(extra_settings: eval(pos_setting_params[:extra_settings]))

        format.html { redirect_to pos_settings_path, notice: 'General Setting was successfully updated.' }
        format.json { render :show, status: :ok, location: @pos_setting }
      else
        format.html { render :edit }
        format.json { render json: @pos_setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pos_settings/1
  # DELETE /pos_settings/1.json
  def destroy
    @pos_setting.destroy
    respond_to do |format|
      format.html { redirect_to pos_settings_url, notice: 'General Setting was successfully destroyed.' }
      format.json { head :no_content }
      format.js   { render :layout => false }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pos_setting
      @pos_setting = PosSetting.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pos_setting_params
      params.require(:pos_setting).permit(
        :name,
        :display_name,
        :phone,
        :account_id,
        :address,
        :sys_type,
        :expiry_date,
        :invoice_note,
        :website,
        :pdf_margin_top,
        :pdf_margin_right,
        :pdf_margin_left,
        :pdf_margin_bottom,
        :purchase_sale_detail_show_page_size,
        :header,
        :footer,
        :header_logo_placement,
        :logo_hieght,
        :logo_width,
        :header_hieght,
        :multi_language,
        :title_padding,
        :gst,
        :ntn,
        :title_style,
        :image_style,
        :header_style,
        :footer_style,
        :footer_address_placement,
        :is_sms,
        :is_qr,
        :sms_user,
        :sms_pass,
        :sms_mask,
        :sms_templates,
        :company_mask,
        :qr_links,
        :extra_settings,
        logo_images: [],
        images: [],
      )
    end
end
