module Admin
  class ThreatFeedsController < BaseController
    before_action :set_threat_feed, only: [:show, :edit, :update, :destroy, :fetch, :toggle]

    def index
      @threat_feeds = ThreatFeed.order(created_at: :desc).page(params[:page])
      @total_feeds = ThreatFeed.count
      @enabled_feeds = ThreatFeed.enabled.count
      @disabled_feeds = ThreatFeed.count - @enabled_feeds
      @feeds_by_type = ThreatFeed.group(:feed_type).count
      @needs_refresh = ThreatFeed.enabled.needs_refresh.count
    end

    def show
    end

    def new
      @threat_feed = ThreatFeed.new
    end

    def create
      @threat_feed = ThreatFeed.new(threat_feed_params)

      if @threat_feed.save
        redirect_to admin_threat_feed_path(@threat_feed), notice: "Threat feed was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @threat_feed.update(threat_feed_params)
        redirect_to admin_threat_feed_path(@threat_feed), notice: "Threat feed was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @threat_feed.destroy
      redirect_to admin_threat_feeds_path, notice: "Threat feed was successfully deleted."
    end

    def fetch
      data = @threat_feed.fetch_data
      if data
        redirect_to admin_threat_feed_path(@threat_feed), notice: "Threat feed data fetched successfully."
      else
        redirect_to admin_threat_feed_path(@threat_feed), alert: "Failed to fetch threat feed data."
      end
    end

    def toggle
      @threat_feed.update(enabled: !@threat_feed.enabled)
      status = @threat_feed.enabled? ? "enabled" : "disabled"
      redirect_to admin_threat_feeds_path, notice: "Threat feed #{status} successfully."
    end

    def bulk_refresh
      feeds = ThreatFeed.enabled.needs_refresh
      success_count = 0
      error_count = 0

      feeds.each do |feed|
        if feed.fetch_data
          success_count += 1
        else
          error_count += 1
        end
      end

      redirect_to admin_threat_feeds_path, 
                  notice: "Refreshed #{success_count} feeds. #{error_count} failed."
    end

    private

    def set_threat_feed
      @threat_feed = ThreatFeed.find(params[:id])
    end

    def threat_feed_params
      params.require(:threat_feed).permit(:name, :url, :feed_type, :enabled, :refresh_interval, :description)
    end
  end
end
