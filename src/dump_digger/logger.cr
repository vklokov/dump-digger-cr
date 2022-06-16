module DumpDigger
  class Logger
    OFFSET = "   "

    def info(message)
      puts "#{OFFSET}[#{Time.local}]: #{message}"
    end
  end
end
