class OptionParser
  class Option
    # type is :positional, :required, :optional, :placed, :none
    # name is option name (e.g. --long-option, -a)
    # arg is option argument (e.g. value, [value], =value)
    # value is removed prefix of space and equal sign (e.g. value, [value], value)
    attr_reader :type, :name, :arg, :value

    def initialize(type, name, arg)
      @type = type
      @name = name
      @arg = arg
      @value = arg&.delete_prefix(' ')&.delete_prefix('=')
    end

    # Option name style in long or short
    # @return [Symbol] :long, :short, nil
    def style
      @style ||= if name&.start_with?('--')
                   :long
                 elsif name&.start_with?('-')
                   :short
                 end
    end

    def self.parse(str)
      return Option.new(:positional, nil, str) unless str.start_with?('-')

      name, arg = split(str)
      type = guess(arg)
      new(type, name, arg)
    end

    # split long option into name and argument
    # @param str [String] option string
    # @return [Array<String, String>] name and argument
    # @example
    #   split('--long-option') # => ['--long-option', nil]
    #   split('--long-option=value') # => ['--long-option', '=value']
    #   split('-a') # => ['-aa', nil]
    #   split('-a=value') # => ['a', '=value']
    def self.split(str)
      if str.start_with?('--')
        name = '--'
        s = str.delete_prefix('--')
        if s.start_with?('[no-]')
          name = '--[no-]'
          s.delete_prefix!('[no-]')
        end

        separator_pos = [s.index(' '), s.index('='), s.index('[')].compact.min

        if separator_pos
          name += s.slice(0, separator_pos)
          arg = s.slice(separator_pos, s.length)
        else
          name += s
          arg = nil
        end
      elsif str.start_with?('-')
        name = str.slice(0..1)
        arg = str.slice(2..)
      else
        raise ArgumentError, "Invalid option: #{str}"
      end

      arg = nil if arg&.empty?
      [name, arg]
    end

    def self.guess(arg)
      return :none unless arg
      return :optional if arg.start_with?('[=')

      a = arg.delete_prefix(' ').delete_prefix('=')

      return :required unless a.start_with?('[')

      case arg[0]
      when ' '
        :placed
      when '='
        :optional
      else
        :required
      end
    end
  end
end
