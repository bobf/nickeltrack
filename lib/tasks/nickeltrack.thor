# frozen_string_literal: true

require 'thor'
require 'logger'
require 'yaml'
require 'erubis'

require 'nickeltrack'

class Nickeltrack < Thor
  desc 'harvest', 'Harvest data from Last.fm'
  def harvest
    logger = Logger.new(STDOUT)
    logger.level = Logger::INFO
    establish_db_connection
    LastFmQuery.new(logger).harvest
  end

  desc 'build', 'Build out static website'
  def build
    view = File.read(
      File.join(base_path, 'lib', 'nickeltrack', 'views', 'index.html.erb')
    )

    establish_db_connection

    result = Erubis::Eruby.new(view).result(
      total_duration: LastFmTrackPlay.sum(:duration),
      activity_chart_points: LastFmTrackPlay.activity_chart_points,
      completion_date: LastFmTrackPlay.completion_date
    )
    File.write(File.join(base_path, 'build', 'index.html'), result)
  end

  private

  def base_path
    @base_path ||= File.expand_path('../..', __dir__)
  end

  def establish_db_connection
    ActiveRecord::Base.establish_connection(
      YAML.load_file(
        File.join(base_path, 'config', 'database.yml')
      )['development']
    )
  end
end
