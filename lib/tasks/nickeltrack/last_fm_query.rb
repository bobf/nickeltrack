require 'faraday'
require 'fuzzy_match'
require 'json'

class LastFmQuery
  def initialize
    @track_info = {}
  end

  def harvest
    mb_query = MusicBrainzQuery.new

    all_track_plays do |track_plays|
      break if track_plays.empty?
      track_plays.each do |track_play|
        mb_tracks = mb_query.recordings(track_play[:artist], track_play[:album])
        next if mb_tracks.nil?
        match = FuzzyMatch.new(
          mb_tracks.map { |track| track[:name] }
        ).find(track_play[:name])

        if (match.nil? &&
            track_play[:name] == 'Mistake - Live in Edmonton, Moi Mix')
          track_play[:duration] = 311000
        elsif match.nil?
          byebug
        else
          track_play[:duration] = mb_tracks.find do |track|
            track[:name] == match
          end[:duration]
        end

        begin
          LastFmTrackPlay.create!(track_play)
        rescue ActiveRecord::RecordNotUnique
          Rails.logger.warn("Non-unique entry found, skipping: #{track_play}")
        end
      end
    end
  end

  private

  def all_track_plays
    page = 1
    loop do
      yield parse_track_plays(track_plays(page))
      Rails.logger.info("Processed page: #{page}")
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
        name: record['name']
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
