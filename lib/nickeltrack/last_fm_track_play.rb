# frozen_string_literal: true

class LastFmTrackPlay < ActiveRecord::Base
  POINT_COUNT = 100
  MASTERY_HOURS = 10_000

  def self.activity_chart_points
    # OPTIMIZE: Do this in one clever SQL query rather than issuing 100 queries.
    # Then again, since this is only run once every few days, do we really
    # care ?
    total = 0
    current = min
    Array.new(POINT_COUNT).map do
      total += duration_over(current, current + increment)
      current += increment
      [Time.strptime(current.to_s, '%s').utc, total / 1000 / 60 / 60]
    end
  end

  def self.completion_date
    Time.now.utc + (total_hours / remaining_hours).hours
  end

  class << self
    def remaining_hours
      @remaining_hours ||= MASTERY_HOURS - (sum(:duration) / 1000 / 60 / 60)
    end

    def total_hours
      @total_hours ||= (Time.now.utc.strftime('%s').to_i - min) * 60
    end

    def min
      @min ||= minimum(:timestamp)
    end

    def max
      @max ||= maximum(:timestamp)
    end

    def increment
      @increment ||= (max - min) / POINT_COUNT
    end

    def duration_over(from, up_to)
      where('timestamp between ? and ?', from, up_to).sum(:duration)
    end
  end
end
