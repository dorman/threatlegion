module Admin
  class DashboardController < BaseController
    def index
      @recent_users = User.order(created_at: :desc).limit(10)
    end
  end
end
