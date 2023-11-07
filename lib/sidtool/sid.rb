module Sidtool
  class Sid
    # Internal attributes for the pokeDigi method
    attr_accessor :internal_start, :internal_repeat_start, :internal_end,
                  :internal_repeat_times, :internal_period, :internal_order,
                  :internal_add, :sample_position, :sample_start, :sample_end,
                  :sample_repeat_start, :sample_repeats, :sample_period,
                  :sample_order, :sample_active

    def initialize
      # Initialize the internal attributes for pokeDigi
      @internal_start = @internal_repeat_start = @internal_end = 0
      @internal_repeat_times = @internal_period = @internal_order = @internal_add = 0
      @sample_position = @sample_start = @sample_end = @sample_repeat_start = 0
      @sample_repeats = @sample_period = @sample_order = @sample_active = 0

      # Existing attributes for voices and control registers
      @voices = [Voice.new, Voice.new, Voice.new]
      @frequency_low = @frequency_high = 0
      @pulse_low = @pulse_high = 0
      @control_register = 0
      @attack_decay = @sustain_release = 0
    end

    # Existing poke method
    def poke(register, value)
      if register >= 0 && register <= 6
        voice = @voices[0]
      elsif register >= 7 && register <= 13
        voice = @voices[1]
        register -= 7
      elsif register >= 14 && register <= 20
        voice = @voices[2]
        register -= 14
      end

      case register
      when 0 then voice.frequency_low = value
      when 1 then voice.frequency_high = value
      when 2 then voice.pulse_low = value
      when 3 then voice.pulse_high = value
      when 4 then voice.control_register = value
      when 5 then voice.attack_decay = value
      when 6 then voice.sustain_release = value
      when 21 then @cutoff_frequency_low = value
      when 22 then @cutoff_frequency_high = value
      when 23 then @resonance_filter = value
      when 24 then @mode_volume = value
      end
    end

    # Existing finish_frame method
    def finish_frame
      @voices.each(&:finish_frame)
    end

    # Existing stop! method
    def stop!
      @voices.each(&:stop!)
    end

    # Existing synths_for_voices method
    def synths_for_voices
      @voices.map(&:synths)
    end

    # Method to handle specific digital audio operations (pokeDigi)
    def pokeDigi(addr, value)
      case addr
      when 0xd41f
        self.internal_start = (self.internal_start & 0x00ff) | (value << 8)
      when 0xd41e
        self.internal_start = (self.internal_start & 0xff00) | value
      when 0xd47f
        self.internal_repeat_start = (self.internal_repeat_start & 0x00ff) | (value << 8)
      when 0xd47e
        self.internal_repeat_start = (self.internal_repeat_start & 0xff00) | value
      when 0xd43e
        self.internal_end = (self.internal_end & 0x00ff) | (value << 8)
      when 0xd43d
        self.internal_end = (self.internal_end & 0xff00) | value
      when 0xd43f
        self.internal_repeat_times = value
      when 0xd45e
        self.internal_period = (self.internal_period & 0x00ff) | (value << 8)
      when 0xd45d
        self.internal_period = (self.internal_period & 0xff00) | value
      when 0xd47d
        self.internal_order = value
      when 0xd45f
        self.internal_add = value
      when 0xd41d
        self.sample_repeats = self.internal_repeat_times
        self.sample_position = self.internal_start
        self.sample_start = self.internal_start
        self.sample_end = self.internal_end
        self.sample_repeat_start = self.internal_repeat_start
        self.sample_period = self.internal_period
        self.sample_order = self.internal_order
        case value
        when 0xfd
          self.sample_active = 0
        when 0xfe, 0xff
          self.sample_active = 1
        else
          return
        end
      end
    end
  end
end
