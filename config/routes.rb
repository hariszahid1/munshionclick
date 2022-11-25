Rails.application.routes.draw do

  resources :remarks
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  resources :compaigns
  resources :compaign_entries
  get 'sms/index'
  get 'sms/sms_to_staff'
  resources :staff_deals
  resources :map_columns
  get :generate_csv, to: 'map_columns#generate_csv'
  resources :property_plans do
    collection do
      get :property_installment, to: 'property_plans#property_installment'
      get :property_installment_bulk, to: 'property_plans#property_installment_bulk'
      put :property_installment_update, to: 'property_plans#update_installment'
      patch :property_installment_update, to: 'property_plans#update_installment'
    end
    member do
      get :property_installment_edit, to: 'property_plans#edit_property_installment'
    end
  end
  resources :product_warranties
  resources :warranties
  resources :product_stocks
  resources :gates
  resources :staff_ledger_books  do
    collection do
      get :transfer, to: 'staff_ledger_books#transfer'
    end
  end
  resources :product_stock_exchanges
  resources :helps
  resources :order_items
  resources :orders do
    collection do
      get :biller, to: 'orders#biller'
      get :auto_print, to: 'orders#auto_print'
      get :print_bulk, to: 'orders#print_bulk'
    end
    member do
      get :transfer, to: 'orders#transfer'
      get :booking_print, to: 'orders#booking_print'
      get :booking_cancel, to: 'orders#booking_cancel'
    end
  end
  resources :production_cycles do
    collection do
      get :jalai, to: 'production_cycles#index_jalai'
      get :nakasi, to: 'production_cycles#index_nakasi'
      get :new_nakasi, to: 'production_cycles#new_nakasi'
      get :new_jalai, to: 'production_cycles#new_jalai'
    end
    member do
      get :edit_jalai, to: 'production_cycles#edit_jalai'
      get :edit_nakasi, to: 'production_cycles#edit_nakasi'
      get :show_jalai, to: 'production_cycles#show_jalai'
      get :show_nakasi, to: 'production_cycles#show_nakasi'
    end
  end
  resources :production_blocks
  resources :production_block_types
  resources :daily_books do
    collection do
      get :khakar, to: 'daily_books#index_khakar'
      get :nakasi, to: 'daily_books#index_nakasi'
      get :new_khakar, to: 'daily_books#new_khakar'
      get :stock_new_khakar, to: 'daily_books#stock_new_khakar'
      get :new_nakasi, to: 'daily_books#new_nakasi'
      get :production_report, to: 'daily_books#production_report'
      get :total_production_report, to: 'daily_books#total_production_report'
    end
    member do
      get :edit_khakar, to: 'daily_books#edit_khakar'
      get :show_khakar, to: 'daily_books#show_khakar'
      get :show_khakar, to: 'daily_books#show_nakasi'
      get :edit_pather_khakar_waste, to: 'daily_books#edit_pather_khakar_waste'
      get :stock_edit_khakar, to: 'daily_books#stock_edit_khakar'
      get :edit_nakasi, to: 'daily_books#edit_nakasi'
    end
  end

  resources :staff_raw_products
  resources :raw_products
  resources :departments
  resources :expense_entries
  resources :salary_details do
    collection do
      get :vehicle, to: 'salary_details#index_vehicle'
      get :khakar, to: 'salary_details#index_khakar'
      get :nakasi, to: 'salary_details#index_nakasi'
      get :pather, to: 'salary_details#index_batha'
      get :khakar_full, to: 'salary_details#index_khakar_full'
      get :advance_all
    end
  end
  get :salary_detail_edit_salaries, to: 'salary_details#edit_bulk', as: :salary_detail_edit_bulk
  get :confirm_index, to: 'payments#confirm_index', as: :confirm_index
  post :confirmable_change, to: 'payments#confirmable_change', as: :confirmable_change
  post :confirmable_change_bulk, to: 'payments#confirmable_change_bulk', as: :confirmable_change_bulk
  post :salary_detail_update_salaries, to: 'salary_details#update_bulk', as: :salary_detail_update_bulk
  resources :payments do
    collection do
      get :transfer, to: 'payments#transfer'
    end
  end
  resources :accounts do
    collection do
      get :account_balance, to: 'accounts#account_balance', as: :account_balance
    end
  end
  resources :logs
  resources :investments
  resources :pos_settings
  resources :ledger_books do
    collection do
      get :transfer, to: 'ledger_books#transfer'
    end
  end
  resources :materials
  resources :productions
  resources :daily_sales
  resources :products  do
    collection do
      get "get_product_data"
    end
  end
  resources :product_sub_categories
  resources :product_categories
  resources :purchase_sale_items
  resources :purchase_sale_details do
    collection do
      get "day_out"
      get "return"
      get "purchase_sale_details_return"
    end
  end

  resources :items do
    collection do
      get "get_item_data"
    end
  end
  resources :item_types
  match 'get_item_type_products/:id', to: 'item_types#get_item_type_products', as: :item_type_products, via: [:get, :post]
  resources :contacts
  resources :sys_users do
    collection do
      get :payable, to: 'sys_users#payable', as: :payable_sys_users
      get :receiveable, to: 'sys_users#receiveable', as: :receiveable
      get :customer, to: 'sys_users#customer', as: :customer
      get :supplier, to: 'sys_users#supplier', as: :supplier
      get :own, to: 'sys_users#own', as: :own

      get :sys_user_balance, to: 'sys_users#sys_user_balance', as: :sys_user_balance
    end
  end

  resources :user_types

  resources :cities
  resources :user_groups
  resources :customer_management_systems
  resources :notes, only: %i[create new]
  resources :follow_ups
  resources :countries
  resources :expense_types
  resources :expenses
  resources :db_backup_files
  get 'home/index'
  get :dashboard, to: 'dashboard#index', as: :dashboard
  get :export, to: 'dashboard#export', as: :export
  get :raw_material, to: 'dashboard#raw_material', as: :raw_material
  get :stock_by_category, to: 'dashboard#stock_by_category', as: :stock_by_category

    resources :bd_backups, only: [:index] do
    collection do
      post :import, as: :import
      get :export, as: :export
    end
  end

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :users, except: :create do
    collection do
      post :create_user
    end
  end
  get 'reports/index'



  get 'reports/chart'
  get 'reports/day_out_report'
  get 'reports/day_check'
  get 'reports/sale_report'
  get 'reports/stock_report'
  get 'reports/product_report'

  get 'reports/chart_of_account'
  get 'reports/trial_balance'
  get 'reports/chart_of_account_report'
  post :bulk_import_data, to: 'bulk_imports#bulk_import_data'
  post :bulk_delete_data, to: 'bulk_imports#bulk_delete_data'

  resources :application do
    member do
      delete :delete_image_attachment
    end
  end
  resources :reports, only: [:index, :chart, :sale_report, :stock_report, :product_report]
  resources :staffs do
    collection do
      get :payable, to: 'staffs#payable', as: :payable
      get :receiveable, to: 'staffs#receiveable', as: :receiveable
      get :dasti, to: 'staffs#dasti', as: :dasti
    end
    member do
      get :salary_info
      get :salary_wage_rate_info
    end
  end

  resources :salaries do
    member do
      get :edit_advance
      get :show_advance
      get :edit_loan
      get :show_loan
    end
    collection do
      get :work_detail
      get :loan
      get :advance
      get :advance_all
    end
  end

  resources :dashboard, only: :index
  root to: "home#index"
end
