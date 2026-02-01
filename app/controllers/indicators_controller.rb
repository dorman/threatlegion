class IndicatorsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_indicator, only: [:show, :edit, :update, :destroy]

  def index
    @q = Indicator.ransack(params[:q])
    @indicators = @q.result.includes(:threat).page(params[:page]).per(50)
  end

  def show
  end

  def new
    @indicator = Indicator.new
    @indicator.threat_id = params[:threat_id] if params[:threat_id]
    @threats = Threat.all
  end

  def create
    @indicator = Indicator.new(indicator_params)

    if @indicator.save
      redirect_to @indicator, notice: "Indicator was successfully created."
    else
      @threats = Threat.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @threats = Threat.all
  end

  def update
    if @indicator.update(indicator_params)
      redirect_to @indicator, notice: "Indicator was successfully updated."
    else
      @threats = Threat.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @indicator.destroy
    redirect_to indicators_url, notice: "Indicator was successfully deleted."
  end

  def search
    @indicators = Indicator.where("value ILIKE ?", "%#{params[:q]}%").limit(100)
    render :index
  end

  private

  def set_indicator
    @indicator = Indicator.find(params[:id])
  end

  def indicator_params
    permitted = params.require(:indicator).permit(:indicator_type, :value, :threat_id, :first_seen, 
                                     :last_seen, :confidence, :source, :tags)
    
    # Convert comma-separated tags string to array
    if permitted[:tags].is_a?(String)
      permitted[:tags] = permitted[:tags].split(',').map(&:strip).reject(&:blank?)
    end
    
    permitted
  end
end
