module Api
  module V1
    class VulnerabilitiesController < BaseController
      def index
        @vulnerabilities = Vulnerability.recent.page(params[:page]).per(params[:per_page] || 25)
        
        render json: {
          vulnerabilities: @vulnerabilities.as_json(include: :threat, methods: :severity_level),
          meta: {
            current_page: @vulnerabilities.current_page,
            total_pages: @vulnerabilities.total_pages,
            total_count: @vulnerabilities.total_count
          }
        }
      end

      def show
        @vulnerability = Vulnerability.find(params[:id])
        render json: @vulnerability.as_json(include: :threat, methods: :severity_level)
      end

      def create
        @vulnerability = Vulnerability.new(vulnerability_params)

        if @vulnerability.save
          render json: @vulnerability, status: :created
        else
          render json: { errors: @vulnerability.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def vulnerability_params
        params.require(:vulnerability).permit(:cve_id, :cvss_score, :description, 
                                             :published_date, :affected_products, :threat_id)
      end
    end
  end
end
