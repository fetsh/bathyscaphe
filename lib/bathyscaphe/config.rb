require "optparse"
require 'yaml'


CONFIG_FILENAME  = File.expand_path("~/.config/bathyscaphe/bathyscaphe.conf")

CONFIG_DEFAULTS = {
  :consumer_key => "",
  :consumer_secret => "",
  :oauth_token => "",
  :oauth_token_secret => "",
  :username => ""
}

module Bathyscaphe
  class Config

    OPTIONS = {
      :dry_run => false
    }

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
      return tv_show
    end

    #
    # Loads configuration parameters.
    #
    def self.load
      @params = CONFIG_DEFAULTS
      if File.exists? config_filename 
        @params.merge! YAML::load_file( config_filename )
      end
    end
    
    #
    # Writes configuration parameters, creating config directory and file 
    # if they do not exist.
    #
    def self.save
      unless File.directory? config_dir
        system "mkdir -p #{config_dir}"
      end
      File.open( config_filename, "w" ) do |f|
        YAML::dump( @params, f )
      end
    end
    
    #
    # Returns a property with the given name.
    #
    def self.method_missing( name, *args )
      if m = /^(.+)=$/.match(name.to_s)
        # set
        @params[m[1].to_sym] = args[0]
      else
        # get
        @params[name.to_sym]
      end
    end
    
    #
    # Returns full path to config file.
    #
    def self.config_filename
      File.expand_path( CONFIG_FILENAME )
    end

    #
    # Returns full path to the directory where config file is located.
    #
    def self.config_dir
      File.dirname( config_filename )
    end
    
  end

  Config.load
  Config.save # creates default config on a fresh installation

end 