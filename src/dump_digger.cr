require "json"
require "option_parser"

require "./dump_digger/version"
require "./dump_digger/analyzer"
require "./dump_digger/logger"

module DumpDigger
  class Main
    def self.version
      puts "DumpDigger version #{DumpDigger::VERSION}"
    end
  end
end

filename : String = ""
generations : Array(String) = [] of String

OptionParser.parse do |opts|
  opts.on("-f FILENAME", "--filename FILENAME", "Set filename") do |name|
    filename = name
  end

  opts.on("-g segments", "--gens segments", "Generations to segment") do |gens|
    generations = gens.split(" ")
  end

  opts.on("-h", "--help", "Show this help") do
    puts opts
  end
end

instance = DumpDigger::Analyzer.new(filename, generations)
instance.analyze
instance.segment_result
