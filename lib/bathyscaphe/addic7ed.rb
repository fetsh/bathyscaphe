module Bathyscaphe
  require "nokogiri"
  require "open-uri"
  require 'net/http'
  require "uri"
  require "tempfile"
  require "fileutils"

  # Class to interact with http://addic7ed.com
  # 
  # === Exaple:
  #
  #  sub = Bathyscaphe::Addic7ed.new(tv_show, season, episode)
  #  sub.save("path/to/save/subtitles")
  #
  class Addic7ed

    HTTP_HOST = "http://addic7ed.com"
    HOST      = "www.addic7ed.com"

    def initialize(tv_show, season, episode)
      @tv_show = tv_show
      @season = season
      @episode = episode
      @temp_file = download
    end

    # Fakes your identity as if you came directly from episode page (otherwise addic7ed will redirect you to this episode page) and downloads subtitles.
    # 
    # Returns object of TempFile with subtitles.
    #
    def download

      uri = URI( download_link )
      path = uri.path.empty? ? "/" : uri.path

      headers = { "Host" => HOST,
                  "Referer" => episode_link(:referer)
                }
      @temp_file = Tempfile.open("bathyscaphe_"+@tv_show+@season+@episode)
      begin
        Net::HTTP.start(uri.host, uri.port) { |http|
          resp = http.get(path, headers)
          @temp_file.write resp.body
          raise "Limit exceeded" if resp.code.to_s == "302"
        }
      rescue Exception => e
        puts e
      ensure
        @temp_file.close
      end

      @temp_file

    end


    # Moves downloaded subtitles to local_path
    #
    def save local_path
      @temp_file ||= download
      FileUtils.mv(@temp_file.path, local_path)
      puts "\e[32m"+"We've downloaded them: #{local_path}"+"\e[0m"
    end


    # Returns direct link to most updated subtitles with highest downloads counter
    #
    def download_link

      html = Nokogiri::HTML( get_html )

      if html.text.empty?
        puts "\e[31m"+"We beliewe addic7ed don't have subtitles for your episode."+"\e[0m"
        puts "   Go check yourself:"
        puts "   #{search_link}"
        exit
      end

      if (search_result = html.xpath("//form[@action='/search.php']").children.xpath("./b")).any?
        if results = search_result.first.text.match(/(\d*) result.{0,1} found/)
          puts "\e[31m"+"Suddenly our bathyscaphe crashed into 'Search results page'"+"\e[0m"
          puts "   They've found #{results[1]} results matching your tv-show name. Go check yourself:"
          puts "   #{search_link}"
          exit
        end
      end

      subtitles = {}
      html.css(".tabel95 .newsDate").each do |td|
        if downloads = td.text.match(/\s(\d*)\sDownloads/i)
          done = false
          td.parent.parent.xpath("./tr/td/a[@class='buttonDownload']/@href").each do |link|
            if md = link.value.match(/updated/i)
              subtitles[downloads[1].to_i] = link.value
              done = true
            elsif link.value.match(/original/i) && done == false
              subtitles[downloads[1].to_i] = link.value
              done = true
            end
          end
        end
      end
     
      if subtitles.empty?
        puts "\e[31m"+"We didn't find your subtitles for some reason."+"\e[0m"
        puts "   Try to find them manually:"
        puts "   #{search_link}"
        exit
      end

      subtitles = subtitles.sort
      puts "\e[32m"+"Found subtitles with #{subtitles.last[0]} downloads: #{HTTP_HOST + subtitles.last[1]}"+"\e[0m"
      
      return HTTP_HOST + subtitles.last[1]
    end

    # Returns Tempfile with html regarding your episode
    #
    def get_html
      io_html = open(episode_link(:lang))
    rescue URI::InvalidURIError => e
      STDERR.puts "\e[31m"+"We generated url the wrong way. Shame on us."+"\e[0m"
      STDERR.puts e
      exit
    rescue OpenURI::HTTPError => the_error
      STDERR.puts "\e[31m"+"Server responded with funny status code #{the_error.io.status[0]}. Haven't seen it yet."+"\e[0m"
      exit
    end

    # Returns properly generated link to the episode page.
    # 
    # === Params
    # Takes symbol as an argument:
    # *:referer* returns link for download method to fake identity.
    # *:lang* returns link with english subtitles for defined episode.
    #
    def episode_link(type = :lang)
      link = URI::escape("http://www.addic7ed.com/serie/#{@tv_show.gsub(" ", "_")}/#{@season}/#{@episode}/")
      link += case type
      when :referer
        "addic7ed"
      when :lang
        "1"
      else
        "1"
      end
    end

    # Returns link to search results for your tv-show name
    # 
    def search_link
      "http://www.addic7ed.com/search.php?search=#{URI::escape(@tv_show)}"
    end

  end
end