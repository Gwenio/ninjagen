NinjaGen is a set of scripts to generate build files for the Ninja build tool.

== Description:

NinjaGen is a set of scripts to generate build files for Ninja (see requirements)
based on YAML configuration files and command line parameters.

The scripts create a 'config' file, a 'tool' file, and a 'project' file.
The 'config' file is the one to point the Ninja tool at, and sets variables and includes other files.
The 'tool' file contains the rules for the tools to be used.
The 'project' file has the actual build targets.

== Design Goals:

- Should not always require modifying config files when files are added or removed from the project.
- Usable for automated build systems.
- Reasonably possible to work out how to build the project manually from the config files.

== Synopsis:

config.rb [options]
tools.rb [options]
project.rb [options]

--help can be used on each script for a list of options.

Each script uses an associated YAML file (config.yml, tools.yml, and project.yml; respectively).

== Requirements:

The Ninja build tool needed to use the output can be found at: https://github.com/martine/ninja

- Ruby 2.0+ with the following standard libraries installed.
  - optparse
  - yaml

== Install:

Just place the four Ruby script files in projects you desire to use it with,
and then write up the configuration files.

== License:

The MIT License (MIT)

Copyright James Adam Armstrong 2014.

License information is included near the top of each script file.

== Status:

Currently supports basic functions suitable for common use cases.

Still needs work to make it more robust and provide better error messages.

Likely there are edge cases where it is currently insufficient.
