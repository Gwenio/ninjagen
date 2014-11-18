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
# See 'config.txt' for details on the structure of the YAML file.

require 'yaml'
require 'optparse'
require './ninjagen'

data = YAML.load_file('config.yml')

varinfo = data['vars'] || {}

raise "'config' cannot be a variable name in 'config.yml'." if varinfo['config']
raise "'tools' cannot be a variable name in 'config.yml'." if varinfo['tools']
raise "'project' cannot be a variable name in 'config.yml'." if varinfo['project']

help = false

config = 'build'

tools = 'tools'

project = 'project'

vars = {}

commands = OptionParser.new do |opts|
  opts.banner = "Usage: config.rb [options]"
  opts.separator ""
  opts.separator "Creates the primary .ninja file."
  opts.separator ""
  opts.separator "Specific options:"
  
  opts.on("--config [NAME]", "The output file will be '[NAME].ninja'.") { |val| config = val }
  
  opts.on("--tools [NAME]", "The file included for rules will be '[NAME].ninja'.") { |val| tools = val }
  
  opts.on("--project [NAME]", "The file included for build targets will be '[NAME].ninja'.") { |val| project = val }
  
  opts.on("--help", "Displays this help message.") { || help = true }
  
  varinfo.each_pair do |var, info|
    raise "'#{var}' is not a valid variable name." unless /\A([a-z]+)\Z/.match(var)
    name = var.to_sym
    if info['hidden'] != false
      vars[name] = info['default']
      opts.on("--#{var} [#{var.upcase}]", info['description']) do |value|
        vars[name] = value
      end
    end
  end
end

if !ARGV.empty?
  commands.parse(ARGV)

end

if help
  puts commands.help
else

  output = NinjaGen.new(File.new("#{config}.ninja", 'w+b'))
  
  output.newline

  output.comment("This file is generated from 'config.yml' by 'config.rb'.\n")
  
  vars.each_pair { |var, value| output.variable(var, value) }
  
  output.newline
  
  files = data['pre']
  
  files.each { |file| output.include(file) } if files

  output.include("#{tools}.ninja")

  output.include("#{project}.ninja")
  
  files = data['post']
  
  files.each { |file| output.include(file) } if files

  output.close()
  
end
