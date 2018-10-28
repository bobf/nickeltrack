# frozen_string_literal: true

require 'thor'
require 'logger'
require 'yaml'
require 'erubis'

require 'nickeltrack'

class NickeltrackTasks < Thor
  desc 'harvest', 'Harvest data from Last.fm'
  def harvest
    $stdout.sync = true
    logger = Logger.new(STDOUT)
    logger.level = Logger::INFO
    establish_db_connection
    Nickeltrack::LastFmQuery.new(logger).harvest
  end

  desc 'build', 'Build out static website'
  def build
    view = File.read(
      File.join(base_path, 'lib', 'nickeltrack', 'views', 'index.html.erb')
    )

    establish_db_connection

    result = Erubis::Eruby.new(view).result(
      total_duration: Nickeltrack::LastFmTrackPlay.sum(:duration),
      activity_chart_points: Nickeltrack::LastFmTrackPlay.activity_chart_points,
      completion_date: Nickeltrack::LastFmTrackPlay.completion_date
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
        File.join(base_path, 'db', 'config.yml')
      )[env]
    )
  end

  def env
    ENV['RAILS_ENV'] || 'development'
  end
end
