module DailyBooksHelper
  def product_quantity_function(daily_book)
    product_quantities = DailyBook.joins(salary_details: :salary_detail_product_quantities).where(id: daily_book).group('salary_detail_product_quantities.product_id').sum('salary_detail_product_quantities.quantity')
  end
  def product_quantity_all_function(date_to,date_from)
    product_quantities = DailyBook.joins(salary_details: :salary_detail_product_quantities).where(created_at: date_to.to_date.beginning_of_day..date_from.to_date.end_of_day).group('salary_detail_product_quantities.product_id').sum('salary_detail_product_quantities.quantity')
  end
end
