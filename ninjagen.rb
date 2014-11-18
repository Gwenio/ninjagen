
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

# A class to manage output of Ninja files.
class NinjaGen

  private

  @id_filter = /\A([a-z]+)\Z/
  
  class << self
    attr_accessor :id_filter
  end

  attr_accessor :file

  # Tests if text is a valid id using the id_filter regex.
  def valid_id(text)
	  NinjaGen.id_filter.match(text)
  end

  # Outputs a list of variables with proper indentation for builds and rules.
  def var_set(vars)
    vars.each_pair do |var, value|
      @file.write("  ")
      variable(var, value)
    end
    @file.write("\n")
  end

  # Outputs a list of items separated by spaces.
  def batch(items)
    if items.is_a?(String)
      @file.write(" #{items}")
    else
      items.each { |item| @file.write(" #{item}") }
    end
  end
  
  public

  # Sets up the instance with an open file.
  def initialize(file)
    @file = file
  end

  # Outputs a comment.
  def comment(text)
    @file.write("# #{text}\n")
  end

  # Outputs an include directive.
  def include(name)
    @file.write("include #{name}\n")
  end

  # Outputs a variable statement.
  def variable(name, value)
    raise "Invalid variable name '#{name}'." unless valid_id(name)
    @file.write("#{name} = #{value}\n")
  end

  # Outputs a build description.
  def build(products, rule, inputs, vars)
    raise "Invalid build name '#{rule}'." unless valid_id(rule)
    @file.write("build")
    batch(products)
    @file.write(": #{rule}")
    batch(inputs)
    newline()
    var_set(vars)
  end

  # Outputs a ninja rule. First parameter is the name, second is a map of variables and their values.
  def command(rule, vars)
    raise "Invalid rule name '#{rule}'." unless valid_id(rule)
    @file.write("rule #{rule}\n  description = #{rule}\n")
    var_set(vars)
  end
  
  # Outputs a new line.
  def newline()
    @file.write("\n")
  end

  # Closes the internal file object.
  def close()
    @file.close
  end

end
