class ThreatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_threat, only: [:show, :edit, :update, :destroy]

  def index
    @q = Threat.ransack(params[:q])
    @threats = @q.result.includes(:user, :indicators).page(params[:page]).per(25)
  end

  def show
    @indicators = @threat.indicators.page(params[:page]).per(20)
    @mitre_attacks = @threat.mitre_attacks
    @vulnerabilities = @threat.vulnerabilities
  end

  def new
    @threat = Threat.new
  end

  def create
    @threat = current_user.threats.build(threat_params)

    if @threat.save
      redirect_to @threat, notice: "Threat was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @threat.update(threat_params)
      redirect_to @threat, notice: "Threat was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @threat.destroy
    redirect_to threats_url, notice: "Threat was successfully deleted."
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
