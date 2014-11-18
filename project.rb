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
# See 'project.txt' for details on the structure of the YAML file.

require 'yaml'
require 'optparse'
require './ninjagen'

name = 'project'
help = false

commands = OptionParser.new do |opts|
  opts.banner = "Usage: project.rb [options]"
  opts.separator ""
  opts.separator "Creates a file containing the project's build targets."
  opts.separator ""
  opts.separator "Specific options:"
  
  opts.on("--project [NAME]", "The output file will be '[NAME].ninja'.") { |val| name = val }
  
  opts.on("--help", "Displays this help message.") { || help = true }
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

  project = YAML.load_file('project.yml')

  output = NinjaGen.new(File.new("#{name}.ninja", 'w+b'))

  output.newline

  output.comment("This file is generated from 'project.yml' by 'project.rb'.\n")

  file_index = {}

  files = project['files']
    
  raise "Project file list not found in 'project.yml'." unless files

  files.each_pair do |name, group|
    list = group['list']
    # check static list
    if !list
      list = []
      blacklist = group['exclude']
      if blacklist
        blacklist = file_index[blacklist.to_sym]
      else
        blacklist = []
      end
      others = group['include']
      # check composite
      if others
        others.each do |other|
          if !blacklist.include?(other)
            list.concat(file_index[other.to_sym])
          end
        end
        list = list.uniq
      else
        glob = group['glob']
        # check dynamic list
        if glob
          glob.each do |g|
            Dir.glob(g) do |file|
              if !blacklist.include?(file)
                list.push(file)
              end
            end
          end
        else # otherwise derive a list
          inputs = file_index[group['derive'].to_sym]
          capture = Regexp.new(group['capture'])
          replace = group['replace']
          pattern = group['pattern']
          inputs.each do |file|
            if !blacklist.include?(file)
              value = String.new(pattern)
              value[replace] = file[capture]
              list.push(value)
            end
          end
        end
      end
    end
    file_index[name.to_sym] = list
  end
  
  spec = project['build']
  
  raise "Project build list not found in 'project.yml'." unless spec
    
  def get_files(groups, index)
    result = []
    temp = []
    groups.each { |group| temp.push(index[group.to_sym].each) }
    first = temp[0]
    temp = temp.slice(1)
    if temp
      first.each do |file|
        store = [file]
        temp.each { |x| store.push(x.next) }
        results.push(store)
      end
    else
      first.each { |file| result.push(file) }
    end
    result
  end

  spec.each do |group|
    rule = group['rule']
    vars = group['vars'] || {}
    if true && group['merge']
      output.build(file_index[group['output'].to_sym], rule, file_index[group['input'].to_sym], vars)
    else
      inputs = get_files(group['input'], file_index)
      outputs = get_files(group['output'], file_index)
      sources = inputs.each
      outputs.each { |product| output.build(product, rule, sources.next, vars) }
    end
  end

  output.close()

end
