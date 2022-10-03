class Crontest < ApplicationRecord
  def self.prune_old_records
    puts "-------------------------------------OrderItems------------------]"
    create!(name: 'conttest')
  end
end
