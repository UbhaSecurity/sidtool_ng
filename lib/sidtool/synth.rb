module Sidtool
  class Synth
    attr_reader :start_frame
    attr_accessor :waveform, :attack, :decay
    attr_reader :sustain_length, :controls
    attr_accessor :release

    # Constants for slide detection and handling
    SLIDE_THRESHOLD = 60 # Threshold for detecting slides
    SLIDE_DURATION_FRAMES = 20 # Duration over which to spread the slide

    def initialize(start_frame)
      @start_frame = start_frame
      @controls = []
      @frequency = nil
      @released_at = nil
    end

    def frequency=(frequency)
      if @frequency
        previous_midi, current_midi = sid_frequency_to_nearest_midi(@frequency), sid_frequency_to_nearest_midi(frequency)

        if slide_detected?(@frequency, frequency)
          handle_slide(previous_midi, current_midi)
        else
          @controls << [STATE.current_frame, current_midi] if previous_midi != current_midi
        end
      end
      @frequency = frequency
    end

    def release!
      return if released?

      @released_at = STATE.current_frame
      length_of_ads = (STATE.current_frame - @start_frame) / FRAMES_PER_SECOND
      @attack, @decay, @sustain_length = adjust_ads(length_of_ads)
    end

    def released?
      !!@released_at
    end

    def stop!
      if released?
        @release = [@release, (STATE.current_frame - @released_at) / FRAMES_PER_SECOND].min
      else
        @release = 0
        release!
      end
    end

    def to_a
      [@start_frame, tone, @waveform, @attack.round(3), @decay.round(3), @sustain_length.round(3), @release.round(3), @controls]
    end

    def tone
      sid_frequency_to_nearest_midi(@frequency)
    end

    def set_frequency_at_frame(frame, frequency)
      return if frame < @start_frame

      relative_frame = frame - @start_frame
      midi_note = sid_frequency_to_nearest_midi(frequency)
      @controls << [relative_frame, midi_note]
    end

    private

    def slide_detected?(old_frequency, new_frequency)
      old_midi, new_midi = sid_frequency_to_nearest_midi(old_frequency), sid_frequency_to_nearest_midi(new_frequency)
      (new_midi - old_midi).abs > SLIDE_THRESHOLD
    end

    def handle_slide(start_midi, end_midi)
      midi_step = (end_midi - start_midi) / SLIDE_DURATION_FRAMES.to_f
      (1..SLIDE_DURATION_FRAMES).each do |frame_offset|
        interpolated_midi = start_midi + (midi_step * frame_offset)
        @controls << [STATE.current_frame + frame_offset, interpolated_midi.round]
      end
    end

    def adjust_ads(length_of_ads)
      if length_of_ads < @attack
        [length_of_ads, 0, 0]
      elsif length_of_ads < @attack + @decay
        [@attack, length_of_ads - @attack, 0]
      else
        [@attack, @decay, length_of_ads - @attack - @decay]
      end
    end

    def sid_frequency_to_nearest_midi(sid_frequency)
      actual_frequency = sid_frequency_to_actual_frequency(sid_frequency)
      nearest_tone(actual_frequency)
    end

    def nearest_tone(frequency)
      midi_tone = (12 * (Math.log(frequency * 0.0022727272727) / Math.log(2))) + 69
      midi_tone.round
    end

    def sid_frequency_to_actual_frequency(sid_frequency)
      (sid_frequency * (CLOCK_FREQUENCY / 16777216)).round(2)
    end
  end
end
