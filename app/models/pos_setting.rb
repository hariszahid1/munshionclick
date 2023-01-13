class PosSetting < ApplicationRecord
  belongs_to :account
  has_many_attached :logo_images
  has_many_attached :images
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  enum sys_type: %i[POS batamega batha industry MobileShop HousingScheme FastFood Draw CustomClear Factory ColdStorage Dealer]
  has_paper_trail ignore: [:updated_at]

  PLACEMENT_OPTIONS = {
    logo_left_text_center: 'img-left-text-center',
    logo_right_text_center: 'img-right-text-center',
    logo_disable_text_center: 'logo_disable_text_center',
    logo_center_text_disable: 'logo_center_text_disable'
  }.freeze

  FOOTER_PLACEMENT_OPTIONS = {
    center: 'center',
    left: 'left',
    right: 'right'
  }.freeze

end
