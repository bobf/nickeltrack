require 'faraday'
require 'json'
require 'byebug'

class LastFmQuery
  def initialize
    @track_info = {}
  end

  def gather
    mb_query = MusicBrainzQuery.new

    all_track_plays do |track_plays|
      break if track_plays.empty?
      track_plays.each do |track_play|
        mb_tracks = mb_query.recordings(track_play[:artist], track_play[:album])
        # TODO: Merge track_play with best match (Levenstein ?) from mb_tracks
        LastFmTrackPlay.create!(track_play)
      end
    end
  end

  private

  def all_track_plays
    page = 217
    loop do
      yield parse_track_plays(track_plays(page))
      puts "Page: #{page}"
      page += 1
    end
  end

  def get(params)
    connection = Faraday.new(url: 'http://ws.audioscrobbler.com')
    connection.get do |request|
      request.url '/2.0/', params
    end.body
  end

  def track_plays(page)
    get(base_params.merge(page: page, method: 'user.getArtistTracks'))
  end

  def parse_track_plays(body)
    data = JSON.parse(body)
    track_plays = data['artisttracks']['track'].map do |record|
      {
        timestamp: record['date']['uts'],
        artist: record['artist']['#text'],
        album: record['album']['#text'],
        name: record['name'],
        mbid: record['mbid']
      }
    end
  end

  def base_params
    params = {
      user: 'bob4realz',
      artist: 'nickelback',
      api_key: '***REMOVED***',
      format: 'json'
    }
  end
end
