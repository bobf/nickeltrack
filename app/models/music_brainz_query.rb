require 'faraday'
require 'json'

class MusicBrainzQuery
  def recordings(artist, album)
    @recordings ||= fetch_recordings(artist, album)
  end

  private

  def fetch_recordings(artist, album)
    connection = Faraday.new(url: 'http://musicbrainz.org')

    reid = release_id(artist, album)
    query = %Q[reid:"#{reid}"]

    response = connection.get do |request|
      request.url(
        '/ws/2/recording/',
        query: query,
        fmt: 'json'
      )
    end

    recordings = JSON.parse(response.body)
    byebug
    recordings['recordings'].map do |recording|
      { name: recording['title'], duration: recording['length'] }
    end
  end

  def release_id(artist, album)
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

    return releases['releases'].first['id'] if disambiguation.nil?

    releases['releases'].find do
      |release| release['disambiguation'] == disambiguation
    end['id']
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
