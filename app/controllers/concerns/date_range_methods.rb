module DateRangeMethods
  extend ActiveSupport::Concern

  def set_date_range
    if params[:q][:created_at].present?
      date = params[:q][:created_at].split(' - ')
      @start_date = date.first.to_date
      @end_date = date.last.to_date
    end
  end
end
