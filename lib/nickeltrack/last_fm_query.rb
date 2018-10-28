# frozen_string_literal: true

require 'faraday'
require 'fuzzy_match'
require 'json'

class LastFmQuery
  def initialize(logger)
    @track_info = {}
    @logger = logger
    @mb_query = MusicBrainzQuery.new(@logger)
    @total_non_unique = 0
    @total_unique = 0
  end

  def harvest
    merged_track_plays do |track_play|
      create_track_play(track_play)
    end
    @logger.info("Total new unique entries: #{@total_unique}")
    @logger.info("Total non-unique entries: #{@total_non_unique}")
  end

  private

  def create_track_play(track_play)
    LastFmTrackPlay.create!(track_play)
    @total_unique += 1
  rescue ActiveRecord::RecordNotUnique
    # Ideally we would exit at this point as it should mean we have caught up to
    # the backlog but, unfortunately, LastFM gives non-unique timestamps in rare
    # instances so I don't think this is reliable enough.
    @logger.debug("Non-unique entry found, skipping: #{track_play}")
    @total_non_unique += 1
  end

  def merged_track_plays
    all_track_plays do |track_plays|
      break if track_plays.empty? # We got to the last page

      album_track_plays(track_plays) { |track_play| yield track_play }
    end
  end

  def album_track_plays(track_plays)
    track_plays.each do |track_play|
      mb_tracks = @mb_query.recordings(track_play[:artist], track_play[:album])
      next if mb_tracks.nil?

      track_play[:duration] = find_duration(track_play, mb_tracks)
      yield track_play
    end
  end

  def find_duration(track_play, mb_tracks)
    match = match_track_name(track_play[:name], mb_tracks)
    special_case_duration = special_case_duration_for(track_play) if match.nil?
    return special_case_duration unless special_case_duration.nil?

    if match.nil?
      @logger.warn("Unable to match: #{track_play[:name]}")
      # These are rare enough that we can ignore them. At the time of writing
      # there is only one instance: the single for "Gem 'Em Up" which is no
      # longer on Spotify.
      return 0
    end

    matched_track = mb_tracks.find { |track| track[:name] == match }
    matched_track[:duration]
  end

  def all_track_plays
    page = 1
    loop do
      yield parse_track_plays(track_plays(page))
      @logger.debug("Processed page: #{page}")
      page += 1
    end
    @logger.info("Processed #{page} pages")
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
    JSON.parse(body)['artisttracks']['track'].map do |record|
      {
        timestamp: record['date']['uts'],
        artist: record['artist']['#text'],
        album: record['album']['#text'],
        name: record['name']
      }
    end
  end

  def match_track_name(track_name, tracks)
    FuzzyMatch.new(tracks.map { |track| track[:name] }).find(track_name)
  end

  def base_params
    {
      user: secrets['username'],
      artist: 'nickelback',
      api_key: secrets['api_key'],
      format: 'json'
    }
  end

  def special_case_duration_for(track_play)
    if track_play[:name] == 'Mistake - Live in Edmonton, Moi Mix'
      return track_play[:duration] = 311_000
    end

    nil
  end

  def secrets
    @secrets ||= YAML.load_file(
      File.join(File.expand_path('../..', __dir__), 'config', 'secrets.yml')
    )['last_fm']
  end
end
