# frozen_string_literal: true

FactoryBot.define do
  factory :last_fm_track_play do
    duration { Faker::Number.between(120_000, 300_000) } # 2 to 5 minutes
    timestamp do
      Faker::Number.between(
        18.months.ago.utc.strftime('%s').to_i,
        Time.now.utc.strftime('%s').to_i
      )
    end
  end
end
