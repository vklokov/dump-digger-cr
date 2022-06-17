require "json"
require "option_parser"

require "./dump_digger/version"
require "./dump_digger/analyzer"
require "./dump_digger/logger"

module DumpDigger
  def self.version
    DumpDigger::VERSION
  end

  def self.analyzer(filename : String, gens : Array(String))
    DumpDigger::Analyzer.new(filename, gens)
  end
end

filename = ""
generations = [] of String

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

instance = DumpDigger.analyzer(filename, generations)
instance.analyze
instance.segment_result
