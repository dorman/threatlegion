class ThreatFeedsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_threat_feed, only: [:show, :edit, :update, :destroy, :fetch]

  def index
    @threat_feeds = ThreatFeed.all
  end

  def show
  end

  def new
    @threat_feed = ThreatFeed.new
  end

  def create
    @threat_feed = ThreatFeed.new(threat_feed_params)

    if @threat_feed.save
      redirect_to @threat_feed, notice: "Threat feed was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @threat_feed.update(threat_feed_params)
      redirect_to @threat_feed, notice: "Threat feed was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @threat_feed.destroy
    redirect_to threat_feeds_url, notice: "Threat feed was successfully deleted."
  end

  def fetch
    data = @threat_feed.fetch_data
    if data
      redirect_to @threat_feed, notice: "Threat feed data fetched successfully."
    else
      redirect_to @threat_feed, alert: "Failed to fetch threat feed data."
    end
  end

  private

  def set_threat_feed
    @threat_feed = ThreatFeed.find(params[:id])
  end

  def threat_feed_params
    params.require(:threat_feed).permit(:name, :url, :feed_type, :enabled, :refresh_interval)
  end
end
