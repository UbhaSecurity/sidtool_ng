require 'sidtool/version'

module Sidtool
  require 'sidtool/file_reader'
  require 'sidtool/ruby_file_writer'
  require 'sidtool/midi_file_writer'
  require 'sidtool/synth'
  require 'sidtool/voice'
  require 'sidtool/sid'
  require 'sidtool/state'

  # PAL properties
  FRAMES_PER_SECOND = 50.0
  CLOCK_FREQUENCY = 985248.0

  # Constants for slide detection and handling
  SLIDE_THRESHOLD = 60 # Adjust as needed
  SLIDE_DURATION_FRAMES = 20 # Adjust as needed

  STATE = State.new
end
