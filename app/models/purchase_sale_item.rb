class PurchaseSaleItem < ApplicationRecord
  belongs_to :purchase_sale_detail, optional: true
  belongs_to :item, optional: true
  belongs_to :product, optional: true
  enum transaction_type: %i[Purchase Sale SaleReturn PurchaseReturn]
  enum purchase_sale_type: %i[Sale_type Return_type]

  after_create :create_item_stock
  after_destroy :destroy_item_stock
  # after_update :update_item_stock
  has_paper_trail ignore: [:updated_at]


  scope :purchase_sale_types_sale_only, -> { where(purchase_sale_type: "Sale_type")}
  scope :purchase_sale_types_return_only, -> { where(purchase_sale_type: "Return_type")}
  def create_item_stock
    if self.item_id? and self.transaction_type=="Purchase"
      if self.purchase_sale_type=="Return_type"
        already_stock = item.stock.present? ? item.stock : 0
        total_stock = already_stock-self.quantity.to_f
        item.update(stock: total_stock)
      else
        already_stock = item.stock.present? ? item.stock : 0
        total_stock = already_stock+self.quantity.to_f
        self.update(remaining_quantity: self.quantity)
        cost_price=((item.cost.to_f*([already_stock, 0].max).to_f)+(self.cost_price.to_f*self.quantity.to_f))/([already_stock, 0].max+self.quantity.to_f)
        item.update(stock: total_stock,cost:cost_price,sale:self.sale_price)
      end
    elsif self.item_id?
      if self.purchase_sale_type=="Return_type"
        already_stock = item.stock.present? ? item.stock : 0
        total_stock = already_stock+self.quantity.to_f
        item.update(stock: total_stock)
      else
        already_stock = item.stock.present? ? item.stock : 0
        total_stock = already_stock-self.quantity.to_f
        item.update(stock: total_stock)
      end
    end

    if self.product_id? and self.transaction_type=="Purchase"
      already_stock = product.stock.present? ? product.stock : 0
      s2_stock = product.size_2.present? ? product.size_2.to_i : 0
      s3_stock = product.size_3.present? ? product.size_3.to_i : 0
      s4_stock = product.size_4.present? ? product.size_4.to_i : 0
      s5_stock = product.size_5.present? ? product.size_5.to_i : 0
      s6_stock = product.size_6.present? ? product.size_6.to_i : 0
      s7_stock = product.size_7.present? ? product.size_7.to_i : 0
      s8_stock = product.size_8.present? ? product.size_8.to_i : 0
      s9_stock = product.size_9.present? ? product.size_9.to_i : 0
      s10_stock = product.size_10.present? ? product.size_10.to_i : 0
      s11_stock = product.size_11.present? ? product.size_11.to_i : 0
      s12_stock = product.size_12.present? ? product.size_12.to_i : 0
      s13_stock = product.size_13.present? ? product.size_13.to_i : 0
      if self.purchase_sale_type=="Return_type"
        total_stock = already_stock-self.quantity.to_f
      else
        total_stock = already_stock+self.quantity.to_f
      end
      ts2_stock = s2_stock+self.size_2.to_i
      ts3_stock = s3_stock+self.size_3.to_i
      ts4_stock = s4_stock+self.size_4.to_i
      ts5_stock = s5_stock+self.size_5.to_i
      ts6_stock = s6_stock+self.size_6.to_i
      ts7_stock = s7_stock+self.size_7.to_i
      ts8_stock = s8_stock+self.size_8.to_i
      ts9_stock = s9_stock+self.size_9.to_i
      ts10_stock = s10_stock+self.size_10.to_i
      ts11_stock = s11_stock+self.size_11.to_i
      ts12_stock = s12_stock+self.size_12.to_i
      ts13_stock = s13_stock+self.size_13.to_i

      cost_price=(((product.cost.to_f*([already_stock, 0].max).to_f)+(self.cost_price.to_f*self.quantity.to_f))/([already_stock, 0].max+self.quantity.to_f)).round(5)
      product.update(stock: total_stock,cost:cost_price,sale:self.sale_price,size_2:ts2_stock,size_3:ts3_stock,size_4:ts4_stock,size_5:ts5_stock,size_6:ts6_stock,size_7:ts7_stock,size_8:ts8_stock,size_9:ts9_stock,size_10:ts10_stock,size_11:ts11_stock,size_12:ts12_stock,size_13:ts13_stock)
      PurchaseSaleItem.where(product_id: self.product_id).where(transaction_type: "Sale").where('extra_quantity<0').each do |purchase|
        quantity=purchase.quantity.to_f-purchase.extra_quantity.to_f.abs
        extra_quantity=purchase.extra_quantity.to_f.abs
        price=purchase.cost_price*quantity
        extra_price=cost_price*extra_quantity
        avg_cost=(price+extra_price)/purchase.quantity
        total_cost=avg_cost*(quantity+extra_quantity)
        purchase.update(cost_price: avg_cost,total_cost_price: total_cost,extra_quantity:0)
      end
    elsif self.product_id?
      self.cost_price = product.cost.to_f
      self.total_cost_price = product.cost.to_f*self.quantity
      self.save!
      already_stock = product.stock.present? ? product.stock : 0
      total_stock = already_stock-self.quantity.to_f
      s2_stock = product.size_2.present? ? product.size_2.to_i : 0
      s3_stock = product.size_3.present? ? product.size_3.to_i : 0
      s4_stock = product.size_4.present? ? product.size_4.to_i : 0
      s5_stock = product.size_5.present? ? product.size_5.to_i : 0
      s6_stock = product.size_6.present? ? product.size_6.to_i : 0
      s7_stock = product.size_7.present? ? product.size_7.to_i : 0
      s8_stock = product.size_8.present? ? product.size_8.to_i : 0
      s9_stock = product.size_9.present? ? product.size_9.to_i : 0
      s10_stock = product.size_10.present? ? product.size_10.to_i : 0
      s11_stock = product.size_11.present? ? product.size_11.to_i : 0
      s12_stock = product.size_12.present? ? product.size_12.to_i : 0
      s13_stock = product.size_13.present? ? product.size_13.to_i : 0
      if self.purchase_sale_type=="Return_type"
        total_stock = already_stock+self.quantity.to_f
      else
        total_stock = already_stock-self.quantity.to_f
      end
      ts2_stock = s2_stock-self.size_2.to_i
      ts3_stock = s3_stock-self.size_3.to_i
      ts4_stock = s4_stock-self.size_4.to_i
      ts5_stock = s5_stock-self.size_5.to_i
      ts6_stock = s6_stock-self.size_6.to_i
      ts7_stock = s7_stock-self.size_7.to_i
      ts8_stock = s8_stock-self.size_8.to_i
      ts9_stock = s9_stock-self.size_9.to_i
      ts10_stock = s10_stock-self.size_10.to_i
      ts11_stock = s11_stock-self.size_11.to_i
      ts12_stock = s12_stock-self.size_12.to_i
      ts13_stock = s13_stock-self.size_13.to_i

      product.update(stock: total_stock,size_2:ts2_stock,size_3:ts3_stock,size_4:ts4_stock,size_5:ts5_stock,size_6:ts6_stock,size_7:ts7_stock,size_8:ts8_stock,size_9:ts9_stock,size_10:ts10_stock,size_11:ts11_stock,size_12:ts12_stock,size_13:ts13_stock)
      # if Production.find_by_product_id(product).present?
      #   items=Production.find_by_product_id(product).materials.pluck(:item_id,:quantity).compact
      #   if items.present?
      #     items.each do |item|
      #       if item.first.present?
      #         stock=Item.find(item.first).stock
      #         total=stock.present? ? stock-(item.last*self.quantity.to_f) : 0-(item.last*self.quantity.to_f)
      #         Item.find(item.first).update(stock: total)
      #       end
      #     end
      #   end
      # end
      # if Production.find_by_product_id(product).present?
      #   products=Production.find_by_product_id(product).materials.pluck(:product_id,:quantity).compact
      #   if products.present?
      #     products.each do |product|
      #       if product.first.present?
      #         stock=Product.find(product.first).stock
      #         total=stock.present? ? stock-(product.last*self.quantity.to_f) : 0-(product.last*self.quantity.to_f)
      #         Product.find(product.first).update(stock: total,cost:self.cost_price,sale:self.sale_price)
      #       end
      #     end
      #   end
      # end

    end
  end

  def destroy_item_stock
    if self.item_id? and self.transaction_type=="Purchase"
      already_stock = item.stock.present? ? item.stock : 0
      if self.purchase_sale_type=="Return_type"
        total_stock = already_stock-self.quantity.to_f
      else
        total_stock = already_stock+self.quantity.to_f
      end
      quantity = (already_stock.to_f-self.quantity.to_f)
      cost = ((already_stock.to_f*self.product&.cost.to_f)-(self.quantity.to_f*self.cost_price.to_f))
      if quantity>0
      cost_price=cost/quantity
      else
        cost_price=self.product&.cost.to_f
      end
      item.update(stock: total_stock,cost:cost_price.to_f,sale:self.sale_price.to_f)
    elsif self.item_id?
      already_stock = item.stock.present? ? item.stock : 0
      if self.purchase_sale_type=="Return_type"
        total_stock = already_stock+self.quantity.to_f
      else
        total_stock = already_stock-self.quantity.to_f
      end
      item.update(stock: total_stock)
    end

    if self.product_id? and self.transaction_type=="Purchase"
      already_stock = product.stock.present? ? product.stock : 0
      if self.purchase_sale_type=="Return_type"
        total_stock = already_stock+self.quantity.to_f
      else
        total_stock = already_stock-self.quantity.to_f
      end
      quantity = (already_stock.to_f-self.quantity.to_f)
      cost = ((already_stock.to_f*self.product&.cost.to_f)-(self.quantity.to_f*self.cost_price.to_f))
      if quantity>0
      cost_price=cost/quantity
      else
        cost_price=self.product&.cost.to_f
      end
      product.update(stock: total_stock,cost:cost_price.to_f,sale:self.sale_price.to_f)
    elsif self.product_id?
      already_stock = product.stock.present? ? product.stock : 0
      if self.purchase_sale_type=="Return_type"
        total_stock = already_stock-self.quantity.to_f
      else
        total_stock = already_stock+self.quantity.to_f
      end
      quantity = (already_stock.to_f+self.quantity.to_f)
      cost = ((already_stock.to_f*self.product&.cost.to_f)+(self.quantity.to_f*self.cost_price.to_f))
      if quantity>0
      cost_price=cost/quantity
      else
        cost_price=self.product&.cost.to_f
      end
      product.update(stock: total_stock,cost:cost_price.to_f)
      # if Production.find_by_product_id(product).present?
      #   items=Production.find_by_product_id(product).materials.pluck(:item_id,:quantity).compact
      #   if items.present?
      #     items.each do |item|
      #       if item.first.present?
      #         stock=Item.find(item.first).stock
      #         total=stock.present? ? stock+(item.last*self.quantity.to_f) : 0+(item.last*self.quantity.to_f)
      #         Item.find(item.first).update(stock: total)
      #       end
      #     end
      #   end
      # end
      # if Production.find_by_product_id(product).present?
      #   products=Production.find_by_product_id(product).materials.pluck(:product_id,:quantity).compact
      #   if products.present?
      #     products.each do |product|
      #       if product.first.present?
      #         stock=Product.find(product.first).stock
      #         total=stock.present? ? stock+(product.last*self.quantity.to_f) : 0+(product.last*self.quantity.to_f)
      #         Product.find(product.first).update(stock: total)
      #       end
      #     end
      #   end
      # end
    end
  end

  def update_item_stock
    if self.product_id?
    # self.product.update(stock: total)
      # self.cost_price = product.cost.to_f
      # self.total_cost_price = product.cost.to_f*self.quantity
      # self.save!
    end
  end
end
