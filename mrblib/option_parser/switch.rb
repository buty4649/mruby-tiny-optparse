class OptionParser
  class Switch
    attr_reader :short, :long, :nolong, :arg, :description, :type, :block

    def initialize(short, long, nolong, arg, description, type, block) # rubocop:disable Metrics/ParameterLists
      @short = short
      @long = long
      @nolong = nolong
      @arg = arg
      @description = description
      @type = type
      @block = block
    end

    def summarize(skip = [], indent = '', width = 32)
      opts = []
      sopts = @short.reject { |s| skip.include?(s) }
      opts += sopts
      opts += @long.reject { |l| skip.include?(l) }
      skip.concat(opts)

      if @nolong.any?
        opts += @nolong.reject { |l| skip.include?("--#{l.slice(5..)}") }

        skip_list = @nolong.map do |option|
          s = option.slice(5..)
          ["--#{option}", "--#{s}"]
        end
        skip.concat(skip_list.flatten.reject { |s| skip.include?(s) })
      end

      return nil if opts.empty?

      left = opts.join(', ')
      left += @arg if @arg
      left = "    #{left}" if sopts.empty?

      format("%s%-#{width}s%s", indent, left, @description ? "  #{@description}" : '')
    end
  end
end
