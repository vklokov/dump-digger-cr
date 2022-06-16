module DumpDigger
  struct Entity
    getter gen, memsize, bytesize, file, line

    def initialize(
      @gen : Int32,
      @memsize : Int32,
      @bytesize : Int32,
      @line : Int32,
      @file : String
    ); end
  end

  class Analyzer
    @result = [] of Entity

    def initialize(
      @filename : String,
      @generations : Array(String),
      @logger : Logger = Logger.new
    ); end

    def analyze
      raise Exception.new("File not found - #{@filename}") unless File.exists?(@filename)

      @logger.info "Analyzing #{@filename}"

      File.each_line(@filename) do |line|
        row = JSON.parse(line)
        if row.dig?("generation")
          @result << DumpDigger::Entity.new(
            row.dig("generation").as_i,
            row.dig?("memsize") ? row["memsize"].as_i : 0,
            row.dig?("bytesize") ? row["bytesize"].as_i : 0,
            row.dig?("line") ? row["line"].as_i : 0,
            row.dig?("file") ? row["file"].as_s : ""
          )
        end
      end

      print_report

      @logger.info "Finish!"
    end

    def segment_result
      @generations.each do |g|
        gi32 = g.to_i
        segment = @result.select { |entity| entity.gen == gi32 }
        group = segment.group_by { |entity| "#{entity.file}:#{entity.line}" }

        @logger.info "* Generate segment #{gi32}"

        File.open(segment_file_name(gi32), "w") do |file|
          group.to_a.sort { |a, b| b[1].size <=> a[1].size }
            .each do |(key, values)|
              file.puts "#{key} [#{(values.sum(&.bytesize).to_f / 1024).round(2)} kb] * #{values.size}"
            end
        end
      end

      @logger.info "Job done!"
    end

    private def segment_file_name(gen)
      "#{@filename}.#{gen}.dump"
    end

    private def print_report
      groupped = @result.group_by(&.gen)
      groupped.keys.sort!.each do |key|
        @logger.info " - Generation: #{key} count: #{groupped[key].size},\
              memsize: #{groupped[key].sum(&.memsize)},\
              bytesize: #{groupped[key].sum(&.bytesize)}"
      end
    end
  end
end
