module Api
  module V1
    class AuthController < ActionController::API
      def login
        user = User.find_by(email: params[:email])

        if user&.valid_password?(params[:password])
          render json: { 
            api_token: user.api_token,
            user: {
              id: user.id,
              email: user.email,
              role: user.role
            }
          }
        else
          render json: { error: "Invalid credentials" }, status: :unauthorized
        end
      end

      def regenerate_token
        token = request.headers["Authorization"]&.split(" ")&.last
        user = User.find_by(api_token: token)

        if user
          user.regenerate_api_token!
          render json: { api_token: user.api_token }
        else
          render json: { error: "Unauthorized" }, status: :unauthorized
        end
      end
    end
  end
end
