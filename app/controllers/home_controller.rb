class HomeController < ApplicationController
  skip_before_action :authenticate_user!
  # layout 'home'
  def index
    redirect_to dashboard_path if user_signed_in? || (request.base_url != "http://munshionclick.com" && request.base_url != "https://munshionclick.com" && request.base_url != "http://localhost:3000" && request.base_url != "https://localhost:3000/")
  end

end
