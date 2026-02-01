module Api
  module V1
    class IndicatorsController < BaseController
      before_action :set_indicator, only: [:show, :update, :destroy]

      def index
        @q = Indicator.ransack(params[:q])
        @indicators = @q.result.page(params[:page]).per(params[:per_page] || 50)
        
        render json: {
          indicators: @indicators.as_json(include: :threat),
          meta: {
            current_page: @indicators.current_page,
            total_pages: @indicators.total_pages,
            total_count: @indicators.total_count
          }
        }
      end

      def show
        render json: @indicator.as_json(include: :threat)
      end

      def create
        @indicator = Indicator.new(indicator_params)

        if @indicator.save
          render json: @indicator, status: :created
        else
          render json: { errors: @indicator.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @indicator.update(indicator_params)
          render json: @indicator
        else
          render json: { errors: @indicator.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @indicator.destroy
        head :no_content
      end

      def search
        value = params[:value]
        @indicators = Indicator.where("value ILIKE ?", "%#{value}%").limit(100)
        render json: @indicators
      end

      private

      def set_indicator
        @indicator = Indicator.find(params[:id])
      end

      def indicator_params
        params.require(:indicator).permit(:indicator_type, :value, :threat_id, :first_seen, 
                                         :last_seen, :confidence, :source, tags: [])
      end
    end
  end
end
