class ExpenseType < ApplicationRecord

  has_paper_trail ignore: [:updated_at]

end
