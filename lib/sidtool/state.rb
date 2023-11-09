module Sidtool
  class State
    attr_accessor :current_frame, :playback_status, :tempo, :clock_rate

    # Define constants or enums for playback status if needed
    PLAYBACK_STATUSES = { stopped: 0, playing: 1, paused: 2 }.freeze

    def initialize
      @current_frame = 0
      @playback_status = PLAYBACK_STATUSES[:stopped]  # Default to stopped
      @tempo = 120  # Default tempo (120 BPM is a common default)
      @clock_rate = 1_000_000  # Default clock rate, can be adjusted based on SID chip specifics
    end

    # Example method to update the state based on playback
    def update_frame
      return unless @playback_status == PLAYBACK_STATUSES[:playing]
      
      # Increment current frame based on tempo or clock rate
      @current_frame += 1
    end

    # Methods to control playback status
    def play
      @playback_status = PLAYBACK_STATUSES[:playing]
    end

    def pause
      @playback_status = PLAYBACK_STATUSES[:paused]
    end

    def stop
      @playback_status = PLAYBACK_STATUSES[:stopped]
      @current_frame = 0
    end

    # Methods for adjusting tempo and clock rate
    def set_tempo(new_tempo)
      # Add validation if necessary
      @tempo = new_tempo
    end

    def adjust_clock_rate(new_clock_rate)
      # Add validation if necessary
      @clock_rate = new_clock_rate
    end
  end
end
