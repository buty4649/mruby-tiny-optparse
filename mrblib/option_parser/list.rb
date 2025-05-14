class OptionParser
  class List
    attr_reader :short, :long, :list

    def initialize
      @short = {}
      @long = {}
      @list = []
    end

    def update(switch, short, long, nolong)
      short&.each { |s| @short[s] = switch }
      long&.each { |l| @long[l] = switch }

      nolong&.each do |option|
        o = option.delete_prefix('--[no-]')
        @long["--#{o}"] = switch
        @long["--no-#{o}"] = switch
      end

      # remove unused switches
      used = @short.values.concat(@long.values)
      @list.delete_if { |s| s.is_a?(Switch) && !used.include?(s) }
    end

    def append(switch, short, long, nolong)
      update(switch, short, long, nolong)
      @list << switch
    end

    def summarize(indent = '', width = 32)
      done = []

      sum = @list.reverse.map do |s|
        if s.respond_to?(:summarize)
          s.summarize(done, indent, width)
        else
          s
        end
      end

      sum.compact.reverse
    end

    def [](option)
      fetch(option)
    end

    def fetch(option)
      key = option.is_a?(Option) ? option.name : option
      @short[key] || @long[key]
    end
  end
end
