# frozen_string_literal: true

require 'digest'
require 'faraday'
require 'json'

class MusicBrainzQuery
  def initialize(logger)
    @logger = logger
    @recordings = {}
  end

  def recordings(artist, album)
    # We don't use the typcial memoisation idiom here because `find_or_create`
    # can return `nil` so we want to avoid re-fetching unnecessarily.
    if @recordings.key?(artist + album)
      @recordings[artist + album]
    else
      @recordings[artist + album] = find_or_create(artist, album)
    end
  end

  private

  def find_or_create(artist, album)
    release = MusicBrainzRelease.find_or_create_by!(
      artist_album_hash: Digest::MD5.hexdigest(artist + album)
    )
    if release.recordings.nil?
      release.recordings = album_recordings(artist, album)
    else
      @logger.info("Using database-cached release info for #{album}")
    end
    release.recordings&.map(&:symbolize_keys)
  end

  def album_recordings(artist, album)
    sleep 1 # Avoid hitting rate limit

    reid = release_id(artist, album)
    @logger.info("Fetched from MusicBrainz: Release ID: #{reid || 'Not found'}")

    return nil if reid.nil?

    recordings = fetch_recordings(reid)
    track_count = recordings.size
    @logger.info("Fetched from MusicBrainz: #{album} (#{track_count} tracks)")
    recordings.map do |recording|
      { 'name' => recording['title'], 'duration' => recording['length'] }
    end
  end

  def release_id(artist, album)
    special_case = special_case_for(album)
    return special_case unless special_case.nil?

    releases = fetch_releases(artist, album)
    return nil if releases.empty?

    disambiguated_album = disambiguated_release(releases, album)
    return disambiguated_album unless disambiguated_album.nil?

    release = try_album_then_single(releases)
    return release unless release.nil?

    @logger.warn("No match found: #{album}")

    nil
  end

  def try_album_then_single(releases)
    album_release = releases.find do |release|
      release['release-group']['primary-type'] == 'Album'
    end

    return album_release['id'] unless album_release.nil?

    single_release = releases.find do |release|
      release['release-group']['primary-type'] == 'Single'
    end

    return nil if single_release.nil?

    single_release['id']
  end

  def fetch_releases(artist, album)
    sleep 1 # Avoid hitting rate limit

    query = %(release:"#{disambiguated(album)}" AND artist:"#{artist}")

    connection = Faraday.new(url: 'http://musicbrainz.org')
    response = connection.get do |request|
      request.url('/ws/2/release/', query: query, fmt: 'json')
    end

    releases = JSON.parse(response.body)['releases']
    @logger.warn("No match found: #{album}") if releases.empty?
    releases
  end

  def fetch_recordings(reid)
    query = %(reid:"#{reid}")
    connection = Faraday.new(url: 'http://musicbrainz.org')
    response = connection.get do |request|
      request.url('/ws/2/recording/', query: query, fmt: 'json')
    end

    JSON.parse(response.body)['recordings']
  end

  def disambiguated_release(releases, album)
    disambiguation = album_disambiguation(album)
    return nil if disambiguation.nil?

    releases.find do |release|
      release['disambiguation'] == disambiguation
    end['id']
  end

  def disambiguated(album)
    album.gsub(/\(.*\)/, '').strip
  end

  def album_disambiguation(album)
    match = album.match(/\((.*)\)/)
    return nil if match.nil?

    match.captures.first
  end

  def special_case_for(album)
    if album == 'Photograph [Commercial Single]'
      return 'b6d57720-6bfd-410d-be82-70d79f88300c'
    end

    nil
  end
end
