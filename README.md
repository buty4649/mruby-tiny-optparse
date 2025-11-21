# mruby-tiny-optparse

A lightweight and linky optparse-style library for mruby.

## Installation

Add this line to your `build_config.rb`:

```ruby
conf.gem :github => 'buty4649/mruby-tiny-optparse'
```

## Usage

```ruby
# Basic usage
opts = OptionParser.new
opts.banner = 'Usage: myapp [options]'

# Define options
opts.on('-v', '--verbose', 'Enable verbose mode') { |v| puts "Verbose: #{v}" }
opts.on('-f', '--file FILE', 'Input file') { |file| puts "File: #{file}" }
opts.on('--count=[NUMBER]', 'Count (optional)') { |n| puts "Count: #{n}" }
opts.on('--[no-]debug', 'Enable/disable debug') { |d| puts "Debug: #{d}" }

# Parse arguments
remaining_args = opts.parse(ARGV)
puts "Remaining args: #{remaining_args}"

# Display help
puts opts.help
```

### Examples

#### Basic flag options
```ruby
opts = OptionParser.new
opts.on('-v', '--verbose', 'Verbose mode') { puts 'Verbose enabled' }
opts.on('-q', '--quiet', 'Quiet mode') { puts 'Quiet enabled' }

opts.parse(['-v', '--quiet'])  # Both callbacks are called
```

#### Options with required arguments
```ruby
opts = OptionParser.new
opts.on('-f', '--file FILE', 'Input file') { |file| puts "Processing: #{file}" }
opts.on('-o OUTPUT', 'Output file') { |output| puts "Output to: #{output}" }

opts.parse(['-f', 'input.txt', '-o', 'output.txt'])
```

#### Options with optional arguments
```ruby
opts = OptionParser.new
opts.on('--count=[NUMBER]', 'Count') { |n| puts "Count: #{n || 'default'}" }

opts.parse(['--count=10'])    # Count: 10
opts.parse(['--count'])       # Count: default
```

#### Boolean toggle options
```ruby
opts = OptionParser.new
opts.on('--[no-]debug', 'Enable/disable debug') { |debug| puts "Debug: #{debug}" }

opts.parse(['--debug'])       # Debug: true
opts.parse(['--no-debug'])    # Debug: false
```

#### Short option concatenation
```ruby
opts = OptionParser.new
opts.on('-a', 'Option A') { puts 'A' }
opts.on('-b', 'Option B') { puts 'B' }
opts.on('-c', 'Option C') { puts 'C' }

opts.parse(['-abc'])  # Prints: A, B, C
```

#### Help text and separators
```ruby
opts = OptionParser.new
opts.banner = 'Usage: myapp [options] files...'
opts.separator ''
opts.separator 'Options:'
opts.on('-v', '--verbose', 'Verbose mode')
opts.separator ''
opts.separator 'Other options:'
opts.on('-h', '--help', 'Show help') { puts opts.help }
```

## Limitation

* Some methods are not implemented
* `parse` method is an alias of `permute` (does not respect `$POSIXLY_CORRECT`)

## License

MIT License
