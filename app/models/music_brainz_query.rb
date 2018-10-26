require 'faraday'
require 'json'

class MusicBrainzQuery
  def gather
    Track.select(:mbid).distinct.each do |track|
      track = Track.find_by(mbid: track.mbid)
      response = fetch(track.mbid)
      data = parse(response.body, track)
      next if data.nil?
      MusicBrainzRecording.create!(data)
      sleep 1 # MusicBrainz rate limiting
    end
  end

  private

  def parse(body, track)
    data = JSON.parse(body)
    puts [data, track.as_json] if data['recordings'].nil? || data['recordings'].empty?
    return if data['recordings'].nil? || data['recordings'].empty?
    {
      length: data['recordings'].first['length'],
      rid: data['recordings'].first['id']
    }
  end

  def fetch(mbid)
    params = "rid:#{mbid}"
    connection = Faraday.new(url: 'http://musicbrainz.org')
    connection.get do |request|
      request.url '/ws/2/recording', query: params, fmt: 'json'
    end
  end
end
