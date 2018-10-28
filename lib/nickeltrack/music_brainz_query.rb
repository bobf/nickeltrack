require 'digest'
require 'faraday'
require 'json'

class MusicBrainzQuery
  def initialize(logger)
    @logger = logger
    @recordings = {}
  end

  def recordings(artist, album)
    @recordings[artist + album] ||= find_or_create(artist, album)
  end

  private

  def find_or_create(artist, album)
    MusicBrainzRelease.find_or_create_by!(
      artist_album_hash: Digest::MD5.hexdigest(artist + album),
      recordings: fetch_recordings(artist, album)
    ).recordings&.map(&:symbolize_keys)
  end

  def fetch_recordings(artist, album)
    sleep 1 # Avoid hitting rate limit

    connection = Faraday.new(url: 'http://musicbrainz.org')

    reid = release_id(artist, album)
    @logger.debug("Fetched release ID: #{reid}")

    return nil if reid.nil?

    query = %Q[reid:"#{reid}"]

    response = connection.get do |request|
      request.url(
        '/ws/2/recording/',
        query: query,
        fmt: 'json'
      )
    end

    recordings = JSON.parse(response.body)
    @logger.info(
      "Fetched #{recordings['recordings'].size} recordings for #{album}"
    )
    recordings['recordings'].map do |recording|
      { 'name' => recording['title'], 'duration' => recording['length'] }
    end
  end

  def release_id(artist, album)
    if album == 'Photograph [Commercial Single]'
      return 'b6d57720-6bfd-410d-be82-70d79f88300c'
    end

    sleep 1 # Avoid hitting rate limit

    connection = Faraday.new(url: 'http://musicbrainz.org')

    query = %Q[release:"#{disambiguated_album(album)}" AND artist:"#{artist}"]

    response = connection.get do |request|
      request.url(
        '/ws/2/release/',
        query: query,
        fmt: 'json'
      )
    end

    releases = JSON.parse(response.body)

    disambiguation = album_disambiguation(album)
    if releases['releases'].empty?
      @logger.warn("No match found: #{album}")
      return nil
    end

    return releases['releases'].find do
      |release| release['disambiguation'] == disambiguation
    end['id'] unless disambiguation.nil?

    release = releases['releases'].find do |release|
      release['release-group']['primary-type'] == 'Album'
    end

    return release['id'] unless release.nil?

    release = releases['releases'].find do |release|
      release['release-group']['primary-type'] == 'Single'
    end

    return release['id'] unless release.nil?

    @logger.warn("No match found: #{album}")

    nil
  end

  def disambiguated_album(album)
    album.gsub(%r{\(.*\)}, '').strip
  end

  def album_disambiguation(album)
    match = album.match(%r{\((.*)\)})
    return nil if match.nil?
    match.captures.first
  end
end
