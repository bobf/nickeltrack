class LastFmTrackPlay < ActiveRecord::Base
  def self.activity_chart_points
    # Aggregated duration for every N plays, where N is (total_plays / total_points)
    point_count = 100
    min = minimum(:timestamp)
    max = maximum(:timestamp)
    increment = (max - min) / point_count
    current = min - increment
    # OPTIMIZE: Do this in SQL rather than issuing 100 queries.
    total = 0
    point_count.times.map do
      current += increment
      total += where('timestamp between ? and ?', current, current + increment)
               .sum(:duration)
      [Time.strptime(current.to_s, '%s').utc, total / 1000 / 60 / 60]
    end
  end

  def self.completion_date
    total_time = Time.now.utc.strftime('%s').to_i - minimum(:timestamp)
    remaining = 10_000 - (sum(:duration) / 1000 / 60 / 60)

    Time.now.utc + ((total_time * 60) / remaining).hours
  end
end
