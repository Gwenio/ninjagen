#!/usr/bin/env ruby

# Copyright (c) 2014 James Adam Armstrong

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

#----------------------

# A simple script to generate a build script from a YAML file.
# See 'tools.txt' for details on the structure of the YAML file.

require 'yaml'
require 'optparse'
require './ninjagen'

config = YAML.load_file('tools.yml')

options = {}

tools = 'tools'

help = false

commands = OptionParser.new do |opts|
  opts.banner = "Usage: tools.rb [options]"
  opts.separator ""
  opts.separator "Creates a file containing build rules for the project."
  opts.separator ""
  opts.separator "Specific options:"
  
  opts.on("--tools [NAME]", "The output file will be '[NAME].ninja'.") { |val| tools = val }
  
  opts.on("--help", "Displays this help message.") { || help = true }
  
  config.each_pair do |name, tool|
    raise "'tools' cannot be a tool name in 'tools.yml'." if name.to_sym == :tools
    map = tool['options']
    selection = "\n\tChoices:\t\tDescription\n"
    map.each_pair { |key, value| selection += "\t-\t#{key}:\t#{value['description']}\n" }
    selection += "\n"
    opts.on("--#{name} [#{name.upcase}]", tool['description'], selection) do |choice|
      options[name] = map[choice]['vars']
    end
  end
end

if !ARGV.empty?
  commands.parse(ARGV)

end

if help
  puts commands.help
else

if help
  puts commands.help
else

  output = NinjaGen.new(File.new("#{tools}.ninja", 'w+b'))
  
  output.newline

  output.comment("This file is generated from 'tools.yml' by 'tools.rb'.\n")

  config.each_key { |name| output.command(name, options[name]) }
  
  output.close

end


