class MitreAttacksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_threat

  def new
    @mitre_attack = @threat.mitre_attacks.build
  end

  def create
    @mitre_attack = @threat.mitre_attacks.build(mitre_attack_params)

    if @mitre_attack.save
      redirect_to @threat, notice: "MITRE ATT&CK technique was successfully added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @mitre_attack = @threat.mitre_attacks.find(params[:id])
    @mitre_attack.destroy
    redirect_to @threat, notice: "MITRE ATT&CK technique was successfully removed."
  end

  private

  def set_threat
    @threat = Threat.find(params[:threat_id])
  end

  def mitre_attack_params
    params.require(:mitre_attack).permit(:tactic, :technique, :technique_id, :description)
  end
end
