# frozen_string_literal: true

RSpec.describe LastFmTrackPlay do
  let(:last_fm_track_play) { build(:last_fm_track_play) }
  subject { last_fm_track_play }
  it { is_expected.to be_a described_class }

  describe '.activity_chart_points' do
    before do
      1000.times { create(:last_fm_track_play) }
    end

    subject { described_class.activity_chart_points }

    it { is_expected.to be_an Array }
  end
end
