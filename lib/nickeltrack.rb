# frozen_string_literal: true

require 'active_record'
require 'fuzzy_match'
require 'faraday'

require 'nickeltrack/version'
require 'nickeltrack/last_fm_track_play'
require 'nickeltrack/music_brainz_release'
require 'nickeltrack/last_fm_query'
require 'nickeltrack/music_brainz_query'
require 'nickeltrack/secrets'

module Nickeltrack; end
