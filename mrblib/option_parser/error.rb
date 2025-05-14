class OptionParser
  class ParseError < StandardError; end
  class InvalidOption < ParseError; end
  class MissingArgument < ParseError; end
  class NeedlessArgument < ParseError; end
end
