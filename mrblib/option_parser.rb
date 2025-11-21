class OptionParser
  attr_accessor :banner, :summary_indent
  attr_reader :summary_width

  def initialize
    @banner = ''
    @summary_indent = '  '
    @summary_width = 32

    @list = List.new
  end

  def summary_width=(width)
    raise ArgumentError, 'width must be Integer' unless width.is_a?(Integer)
    raise ArgumentError, 'width must be positive' if width <= 0

    @summary_width = width
  end

  def on(*opts, &block)
    short = []
    long = []
    nolong = []
    arg = nil
    description = nil
    type = :none

    opts.each do |opt|
      o = Option.parse(opt)
      if o.type == :positional
        description = o.arg
        next
      end

      if o.style == :short
        short << o.name
      elsif o.name.start_with?('--[no-]')
        nolong << o.name
      else
        long << o.name
      end

      arg = o.arg

      if type == :none
        type = o.type
      elsif type != o.type
        raise ArgumentError, "Argument type mismatch: #{type} != #{o.type}"
      end
    end

    switch = Switch.new(short, long, nolong, arg, description, type, block)
    @list.append(switch, short, long, nolong)

    self
  end

  def parse(args)
    parse!(args.dup)
  end

  def parse!(args)
    while (arg = args.shift)
      break if arg == '--'

      o = Option.parse(arg)
      if o.type == :positional
        args.unshift(arg)
        break
      end

      switch = @list[o]

      raise InvalidOption, "invalid option: #{arg}" unless switch

      value = o.value

      if switch.type == :none
        if o.style == :long
          raise NeedlessArgument, "option does not take an argument: #{arg}" if value

          value = !o.name.start_with?('--no-')

        elsif value
          v = "-#{value}"
          # Concatenated short options(e.g. -ab)
          raise NeedlessArgument, "option does not take an argument: #{arg}" unless @list[v.slice(0..1)]

          args.unshift(v)
          value = true

        else
          value = true
        end
      elsif switch.type == :required && value.nil?
        value = args.shift
        raise MissingArgument, "option requires an argument: #{arg}" unless value
      elsif switch.type == :placed && !args&.first&.start_with?('-')
        value = args.shift
      end

      switch.block&.call(value)
    end

    args
  end

  def separator(str)
    @list.append(str, nil, nil, nil)
  end

  def summarize
    @list.summarize(@summary_indent, @summary_width)
  end

  def help
    (banner.empty? ? '' : "#{banner}\n") + summarize.join("\n")
  end
end
