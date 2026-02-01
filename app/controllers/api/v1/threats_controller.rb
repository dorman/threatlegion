module Api
  module V1
    class ThreatsController < BaseController
      before_action :set_threat, only: [:show, :update, :destroy]

      def index
        @q = Threat.ransack(params[:q])
        @threats = @q.result.page(params[:page]).per(params[:per_page] || 25)
        
        render json: {
          threats: @threats.as_json(include: [:indicators, :mitre_attacks, :vulnerabilities]),
          meta: {
            current_page: @threats.current_page,
            total_pages: @threats.total_pages,
            total_count: @threats.total_count
          }
        }
      end

      def show
        render json: @threat.as_json(include: [:indicators, :mitre_attacks, :vulnerabilities, :user])
      end

      def create
        @threat = current_user.threats.build(threat_params)

        if @threat.save
          render json: @threat, status: :created
        else
          render json: { errors: @threat.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @threat.update(threat_params)
          render json: @threat
        else
          render json: { errors: @threat.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @threat.destroy
        head :no_content
      end

      private

      def set_threat
        @threat = Threat.find(params[:id])
      end

      def threat_params
        params.require(:threat).permit(:name, :threat_type, :severity, :description, :status, 
                                       :first_seen, :last_seen, :confidence_score)
      end
    end
  end
end
