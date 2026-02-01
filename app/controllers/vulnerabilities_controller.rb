class VulnerabilitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_vulnerability, only: [:show, :edit, :update, :destroy]

  def index
    @vulnerabilities = Vulnerability.includes(:threat).recent.page(params[:page]).per(25)
  end

  def show
  end

  def new
    @vulnerability = Vulnerability.new
    @vulnerability.threat_id = params[:threat_id] if params[:threat_id]
    @threats = Threat.all
  end

  def create
    @vulnerability = Vulnerability.new(vulnerability_params)

    if @vulnerability.save
      redirect_to @vulnerability, notice: "Vulnerability was successfully created."
    else
      @threats = Threat.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @threats = Threat.all
  end

  def update
    if @vulnerability.update(vulnerability_params)
      redirect_to @vulnerability, notice: "Vulnerability was successfully updated."
    else
      @threats = Threat.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @vulnerability.destroy
    redirect_to vulnerabilities_url, notice: "Vulnerability was successfully deleted."
  end

  private

  def set_vulnerability
    @vulnerability = Vulnerability.find(params[:id])
  end

  def vulnerability_params
    params.require(:vulnerability).permit(:cve_id, :cvss_score, :description, 
                                         :published_date, :affected_products, :threat_id)
  end
end
