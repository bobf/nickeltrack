require 'faraday'
require 'json'

class Nickeltracker
  def gather
    tracks = []
    while true
      response = tracker.get
      tracks += tracker.parse(response.body)
      break if tracks.empty?
    end
    return tracks
  end

  private

  def get
    params = {
      user: 'bob4realz',
      artist: 'nickelback',
      api_key: '***REMOVED***',
      page: 5,
      format: 'json',
      method: 'user.getartisttracks'
    }

    connection = Faraday.new(url: 'http://ws.audioscrobbler.com')
    connection.get do |req|
      req.url '/2.0/', params
    end
  end

  def parse(body)
    data = JSON.parse(body)
    tracks = data['artisttracks'].map do |record|
      {
        timestamp: record['track'].first['date']['uts']
        artist: record['track'].first['artist']['#text']
        album: record['track'].first['album']['#text']
        name: record['track'].first['name']
      }
    end
  end
end

tracker = Nickeltracker.new
tracker.gather
