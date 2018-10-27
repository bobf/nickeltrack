class HomeController < ApplicationController
  def index
    @total_duration = LastFmTrackPlay.sum(:duration)
    @activity_chart_points = LastFmTrackPlay.activity_chart_points
    @completion_date = LastFmTrackPlay.completion_date
  end
end
