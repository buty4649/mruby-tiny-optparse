assert('OptionParser#initialize') do
  parser = OptionParser.new
  assert_equal '', parser.banner, 'banner should be empty string by default'
  assert_equal '  ', parser.summary_indent, 'summary_indent should be two spaces by default'
  assert_equal 32, parser.summary_width, 'summary_width should be 32 by default'
end

assert('OptionParser#summary_width=') do
  parser = OptionParser.new
  parser.summary_width = 40
  assert_equal 40, parser.summary_width, 'summary_width should be set to 40'

  assert_raise(ArgumentError, 'negative width should raise ArgumentError') { parser.summary_width = -1 }
  assert_raise(ArgumentError, 'zero width should raise ArgumentError') { parser.summary_width = 0 }
  assert_raise(ArgumentError, 'non-integer width should raise ArgumentError') { parser.summary_width = 'invalid' }
end

assert('OptionParser#on') do
  def parser
    parser = OptionParser.new
    class << parser
      attr_reader :list
    end
    parser
  end

  assert('with short option') do
    got = parser.on('-v', 'verbose mode')

    assert_equal %w[-v], got.list.short.keys
    assert_equal 'verbose mode', got.list['-v'].description
    assert_equal :none, got.list['-v'].type
    assert_equal [], got.list.long.keys
  end

  assert('with long option') do
    got = parser.on('--verbose', 'verbose mode')

    assert_equal [], got.list.short.keys
    assert_equal %w[--verbose], got.list.long.keys
    assert_equal 'verbose mode', got.list['--verbose'].description
    assert_equal :none, got.list['--verbose'].type
  end

  assert('with required argument') do
    got = parser.on('-f', '--file FILE', 'specify file')

    assert_equal %w[-f], got.list.short.keys
    assert_equal %w[--file], got.list.long.keys
    assert_same got.list['--file'], got.list['-f']
    assert_equal 'specify file', got.list['-f'].description
    assert_equal :required, got.list['-f'].type
    assert_equal ' FILE', got.list['-f'].arg
  end

  assert('with optional argument') do
    got = parser.on('-f', '--file [FILE]', 'specify file')

    assert_equal %w[-f], got.list.short.keys
    assert_equal %w[--file], got.list.long.keys
    assert_same got.list['--file'], got.list['-f']
    assert_equal 'specify file', got.list['-f'].description
    assert_equal :placed, got.list['-f'].type
    assert_equal ' [FILE]', got.list['-f'].arg
  end

  assert('with --[no-]option pattern') do
    got = parser.on('--[no-]verbose', 'verbose mode')

    assert_equal %w[--verbose --no-verbose], got.list.long.keys
    assert_equal 'verbose mode', got.list['--verbose'].description
    assert_equal :none, got.list['--verbose'].type
    assert_equal %w[--[no-]verbose], got.list['--verbose'].nolong
  end

  assert('with block') do
    got = parser.on('-v', 'verbose mode') { |v| _ = v }

    assert_equal %w[-v], got.list.short.keys
    assert_false got.list['-v'].block.nil?
  end
end

assert('OptionParser#order') do
  parser = OptionParser.new
  args = %w[-a -b foo]
  assert_stub = lambda do |a, &b|
    assert_equal %w[-a -b foo], a
    assert_not_same args, a
    assert_false b.nil?
  end

  parser.stub(:order!, assert_stub) do
    parser.order(args) { |s| _ = s }
  end
end

assert('OptionParser#order!') do
  def parser
    OptionParser.new
  end

  assert('with short option') do
    result = nil
    args = %w[-v]
    remaining = parser.on('-v') { |v| result = v }
                      .order!(args)
    assert_true result
    assert_equal [], remaining
    assert_equal [], args
  end

  assert('with long option') do
    result = nil
    args = %w[--verbose]
    remaining = parser.on('--verbose') { |v| result = v }
                      .order!(args)
    assert_true result
    assert_equal [], remaining
    assert_equal [], args
  end

  assert('with required argument') do
    result = nil
    args = %w[--file test.txt]
    remaining = parser.on('-f', '--file FILE') { |f| result = f }
                      .order!(args)
    assert_equal 'test.txt', result
    assert_equal [], remaining
    assert_equal [], args
  end

  assert('with optional argument') do
    result = nil
    args = %w[--file test.txt]
    remaining = parser.on('-f', '--file [FILE]') { |f| result = f }
                      .order!(args)
    assert_equal 'test.txt', result
    assert_equal [], remaining
    assert_equal [], args

    result = nil
    args = %w[--file]
    remaining = parser.on('-f', '--file [FILE]') { |f| result = f }
                      .order!(args)
    assert_nil result
    assert_equal [], remaining
    assert_equal [], args
  end

  assert('with --[no-]option pattern') do
    result = nil
    args = %w[--verbose]
    remaining = parser.on('--[no-]verbose') { |v| result = v }
                      .order!(args)
    assert_true result
    assert_equal [], remaining
    assert_equal [], args

    result = nil
    args = %w[--no-verbose]
    remaining = parser.on('--[no-]verbose') { |v| result = v }
                      .order!(args)
    assert_false result
    assert_equal [], remaining
    assert_equal [], args
  end

  assert('with positional arguments') do
    result_a = nil
    result_b = nil
    args = %w[-a foo -b]
    remaining = parser.on('-a') { |a| result_a = a }
                      .on('-b') { |b| result_b = b }
                      .order!(args)
    assert_true result_a
    assert_nil result_b
    assert_equal %w[foo -b], remaining
    assert_equal %w[foo -b], args
  end

  assert('with mixed options and positional arguments') do
    result_v = nil
    result_f = nil
    args = %w[-v input.txt --file output.txt remaining args]
    remaining = parser.on('-v', '--verbose') { |v| result_v = v }
                      .on('-f', '--file FILE') { |f| result_f = f }
                      .order!(args)
    assert_true result_v
    assert_nil result_f # --file won't be parsed after encountering positional argument
    assert_equal %w[input.txt --file output.txt remaining args], remaining
    assert_equal %w[input.txt --file output.txt remaining args], args
  end

  assert('with options before positional arguments') do
    result_v = nil
    result_f = nil
    args = %w[--file output.txt -v input.txt remaining args]
    remaining = parser.on('-v', '--verbose') { |v| result_v = v }
                      .on('-f', '--file FILE') { |f| result_f = f }
                      .order!(args)
    assert_true result_v
    assert_equal 'output.txt', result_f
    assert_equal %w[input.txt remaining args], remaining
    assert_equal %w[input.txt remaining args], args
  end

  assert('with -- separator') do
    result_a = nil
    result_b = nil
    result_c = nil
    args = %w[-a foo -- -b -c]
    remaining = parser.on('-a') { |a| result_a = a }
                      .on('-b') { |b| result_b = b }
                      .on('-c') { |c| result_c = c }
                      .order!(args)
    assert_true result_a
    assert_nil result_b
    assert_nil result_c
    assert_equal %w[foo -- -b -c], remaining
    assert_equal %w[foo -- -b -c], args
  end

  assert('with -- separator and no arguments before') do
    result_a = nil
    result_b = nil
    args = %w[-- -a -b]
    remaining = parser.on('-a') { |a| result_a = a }
                      .on('-b') { |b| result_b = b }
                      .order!(args)
    assert_nil result_a
    assert_nil result_b
    assert_equal %w[-a -b], remaining
    assert_equal %w[-a -b], args
  end

  assert('with block to handle positional arguments') do
    result_v = nil
    positional_args = []
    args = %w[-v file1.txt file2.txt --verbose file3.txt]
    remaining = parser.on('-v', '--verbose') { |v| result_v = v }
                      .order!(args) { |arg| positional_args << arg }
    assert_true result_v
    assert_equal %w[file1.txt file2.txt file3.txt], positional_args
    assert_equal [], remaining
    assert_equal [], args
  end

  assert('with block processing mixed options and positional arguments') do
    result_f = nil
    positional_args = []
    args = %w[--file config.txt input1.txt -v input2.txt output.txt]
    remaining = parser.on('-f', '--file FILE') { |f| result_f = f }
                      .on('-v', '--verbose')
                      .order!(args) { |arg| positional_args << arg }
    assert_equal 'config.txt', result_f
    assert_equal %w[input1.txt input2.txt output.txt], positional_args
    assert_equal [], remaining
    assert_equal [], args
  end

  assert('with block and -- separator') do
    result_a = nil
    positional_args = []
    args = %w[-a file1.txt -- --file file2.txt -b]
    remaining = parser.on('-a') { |a| result_a = a }
                      .on('-b')
                      .on('--file FILE')
                      .order!(args) { |arg| positional_args << arg }
    assert_true result_a
    assert_equal %w[file1.txt], positional_args
    assert_equal %w[--file file2.txt -b], remaining
    assert_equal %w[--file file2.txt -b], args
  end
end

assert('OptionParser#permute!') do
  def parser
    OptionParser.new
  end

  assert('with short option') do
    result = nil
    args = %w[-v]
    remaining = parser.on('-v') { |v| result = v }
                      .permute!(args)
    assert_true result
    assert_equal [], remaining
    assert_equal [], args
  end

  assert('with long option') do
    result = nil
    args = %w[--verbose]
    remaining = parser.on('--verbose') { |v| result = v }
                      .permute!(args)
    assert_true result
    assert_equal [], remaining
    assert_equal [], args
  end

  assert('with required argument') do
    result = nil
    args = %w[--file test.txt]
    remaining = parser.on('-f', '--file FILE') { |f| result = f }
                      .permute!(args)
    assert_equal 'test.txt', result
    assert_equal [], remaining
    assert_equal [], args
  end

  assert('with optional argument') do
    result = nil
    args = %w[--file test.txt]
    remaining = parser.on('-f', '--file [FILE]') { |f| result = f }
                      .permute!(args)
    assert_equal 'test.txt', result
    assert_equal [], remaining
    assert_equal [], args

    result = nil
    args = %w[--file]
    remaining = parser.on('-f', '--file [FILE]') { |f| result = f }
                      .permute!(args)
    assert_nil result
    assert_equal [], remaining
    assert_equal [], args
  end

  assert('with --[no-]option pattern') do
    result = nil
    args = %w[--verbose]
    remaining = parser.on('--[no-]verbose') { |v| result = v }
                      .permute!(args)
    assert_true result
    assert_equal [], remaining
    assert_equal [], args

    result = nil
    args = %w[--no-verbose]
    remaining = parser.on('--[no-]verbose') { |v| result = v }
                      .permute!(args)
    assert_false result
    assert_equal [], remaining
    assert_equal [], args
  end

  assert('with positional arguments') do
    result_a = nil
    result_b = nil
    args = %w[-a foo -b]
    remaining = parser.on('-a') { |a| result_a = a }
                      .on('-b') { |b| result_b = b }
                      .permute!(args)
    assert_true result_a
    assert_true result_b
    assert_equal %w[foo], remaining
    assert_equal %w[foo], args
  end

  assert('with mixed options and positional arguments') do
    result_v = nil
    result_f = nil
    args = %w[-v input.txt --file output.txt remaining args]
    remaining = parser.on('-v', '--verbose') { |v| result_v = v }
                      .on('-f', '--file FILE') { |f| result_f = f }
                      .permute!(args)
    assert_true result_v
    assert_equal 'output.txt', result_f
    assert_equal %w[input.txt remaining args], remaining
    assert_equal %w[input.txt remaining args], args
  end

  assert('with options before positional arguments') do
    result_v = nil
    result_f = nil
    args = %w[--file output.txt -v input.txt remaining args]
    remaining = parser.on('-v', '--verbose') { |v| result_v = v }
                      .on('-f', '--file FILE') { |f| result_f = f }
                      .permute!(args)
    assert_true result_v
    assert_equal 'output.txt', result_f
    assert_equal %w[input.txt remaining args], remaining
    assert_equal %w[input.txt remaining args], args
  end

  assert('with -- separator') do
    result_a = nil
    result_b = nil
    result_c = nil
    args = %w[-a foo -- -b -c]
    remaining = parser.on('-a') { |a| result_a = a }
                      .on('-b') { |b| result_b = b }
                      .on('-c') { |c| result_c = c }
                      .permute!(args)
    assert_true result_a
    assert_nil result_b
    assert_nil result_c
    assert_equal %w[foo -b -c], remaining
    assert_equal %w[foo -b -c], args
  end

  assert('with -- separator and no arguments before') do
    result_a = nil
    result_b = nil
    args = %w[-- -a -b]
    remaining = parser.on('-a') { |a| result_a = a }
                      .on('-b') { |b| result_b = b }
                      .permute!(args)
    assert_nil result_a
    assert_nil result_b
    assert_equal %w[-a -b], remaining
    assert_equal %w[-a -b], args
  end
end

assert('OptionParser#parse') do
  skip 'In mruby, alias methods do not return true for equality'
  parser = OptionParser.new
  assert_equal parser.method(:permute), parser.method(:parse)
end

assert('OptionParser#parse!') do
  skip 'In mruby, alias methods do not return true for equality'
  parser = OptionParser.new
  assert_equal parser.method(:permute!), parser.method(:parse!)
end

assert('OptionParser#help') do
  parser = OptionParser.new
  parser.banner = 'Usage: test [options]'
  parser.on('-v', '--verbose', 'verbose mode')
  parser.on('-f', '--file FILE', 'specify file')
  parser.on('--[no-]debug', 'debug mode')
  parser.separator('')
  parser.separator('Common options:')

  expected = <<~EXPECTED.chomp
    Usage: test [options]
      -v, --verbose                     verbose mode
      -f, --file FILE                   specify file
          --[no-]debug                  debug mode

    Common options:
  EXPECTED

  assert_equal expected, parser.help, 'help should show options with default indentation and width'

  assert('with custom summary_indent') do
    parser = OptionParser.new
    parser.banner = 'Usage: test [options]'
    parser.on('-v', '--verbose', 'verbose mode')
    parser.on('-f', '--file FILE', 'specify file')
    parser.separator('')
    parser.separator('Common options:')
    parser.summary_indent = '    '

    expected = <<~EXPECTED.chomp
      Usage: test [options]
          -v, --verbose                     verbose mode
          -f, --file FILE                   specify file

      Common options:
    EXPECTED

    assert_equal expected, parser.help, 'help should show options with custom indentation (4 spaces)'
  end

  assert('with custom summary_width') do
    parser = OptionParser.new
    parser.banner = 'Usage: test [options]'
    parser.on('-v', '--verbose', 'verbose mode')
    parser.on('-f', '--file FILE', 'specify file')
    parser.separator('')
    parser.separator('Common options:')
    parser.summary_width = 20

    expected = <<~EXPECTED.chomp
      Usage: test [options]
        -v, --verbose         verbose mode
        -f, --file FILE       specify file

      Common options:
    EXPECTED

    assert_equal expected, parser.help, 'help should show options with custom width (20)'
  end
end
