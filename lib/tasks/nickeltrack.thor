require File.join(File.expand_path('../../', __dir__), 'config/environment.rb')
class Nickeltrack < Thor
  desc 'gather', 'Fetch data from Last.fm'
  def gather
    LastFmQuery.new.gather
    # MusicBrainzQuery.new.gather
  end
end
