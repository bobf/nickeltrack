RSpec.describe LastFmQuery do
  let(:last_fm_query) { described_class.new }
  subject { last_fm_query }
  it { is_expected.to be_a described_class }

  let(:track) do
    {
      artist: 'Nickelback',
      album: 'Feed the Machine',
      name: 'Coin for the Ferryman',
      mbid: '1234-1234-1234-1234',
      timestamp: '123123123'
    }
  end

  let(:tracks_data) do
    {
      artisttracks: {
        track: [
          {
            date: track[:timestamp],
            artist: { '#text' => track[:artist] },
            album: { '#text' => track[:album] },
            name: track[:name],
            mbid: track[:mbid]
          }
        ]
      }
    }
  end

  let(:empty_tracks_data) do
    {
      artisttracks: {
        track: []
      }
    }
  end

  let(:track_info) do
    {
      track: {
        duration: 12345,
        mbid: '4321-4321-4321-4321'
      }
    }
  end

  before do
    stub_request(:get, %r{http://ws.audioscrobbler.com})
      .with(query: hash_including(method: 'user.getArtistTracks'))
      .to_return(
        { body: tracks_data.to_json },
        { body: empty_tracks_data.to_json }
      )

    stub_request(:get, %r{http://ws.audioscrobbler.com})
      .with(query: hash_including(method: 'track.getInfo'))
      .to_return(body: track_info.to_json)
  end

  describe '#gather' do
    subject { proc { last_fm_query.gather } }
    it { is_expected.to change { LastFmTrackInfo.count }.by(1) }
    it { is_expected.to change { LastFmTrackPlay.count }.by(1) }
  end
end
