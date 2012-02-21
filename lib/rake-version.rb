
require 'rake/tasklib'

module RakeVersion
  VERSION = File.open(File.join(File.dirname(__FILE__), '..', 'VERSION'), 'r').read

  class Tasks < ::Rake::TaskLib
  end
end
