require "optparse"

module Bathyscaphe
  class Config
    OPTIONS = { dry_run: false }

    def self.parse_options
      options = {}
      optparser = OptionParser.new do |opts|
        opts.set_summary_indent('  ')
        opts.banner = "Usage: #{File.basename($0)} [OPTIONS] TV_SHOW"
        # opts.on( "-s", "--source SOURCE", String, "Set source to download subtitles from","Current: #{self.source}" ) { |o| self.source = o ; self.save }
        opts.on( "-d", "--dry-run", "Parse filename but do not download anything") { |o| OPTIONS[:dry_run] = o}
        opts.on( "-v", "--version", "Show version") do
          options[:version] = true
          puts Bathyscaphe::VERSION
        end
        opts.on_tail( "-h", "--help", "Show usage") do
          puts opts
          exit
        end
      end
      # Parse command line
      begin
        optparser.parse!
        if ARGV.empty?
          puts optparser unless options[:version]
          exit
        else
          tv_show = ARGV[0]
        end
      rescue OptionParser::ParseError => e
        puts e
        puts optparser
        exit
      end
    end
  end
end
