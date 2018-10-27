require File.join(File.expand_path('../../', __dir__), 'config/environment.rb')

require_relative 'nickeltrack/last_fm_query'
require_relative 'nickeltrack/music_brainz_query'

require 'logger'

Rails.logger = Logger.new(STDOUT)
Rails.logger.level = Logger::INFO

class Nickeltrack < Thor
  desc 'harvest', 'Harvest data from Last.fm'
  def harvest
    LastFmQuery.new.harvest
  end
end
