module Bathyscaphe
  require "nokogiri"
  require "open-uri"
  require 'net/http'
  require "uri"
  require "tempfile"
  require "fileutils"

  class Addic7ed

    HTTP_HOST = "http://addic7ed.com"
    HOST      = "www.addic7ed.com"

    def initialize(tv_show, season, episode)
      @tv_show = tv_show
      @season = season
      @episode = episode
      @temp_file = download
    end

    def download

      uri = URI(HTTP_HOST + sub_link)
      path = uri.path.empty? ? "/" : uri.path

      headers = { "Host" => HOST,
                  "Referer" => show_page(:referer)
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

    def save local_path
      @temp_file ||= download
      FileUtils.mv(@temp_file.path, local_path)
    end

    def sub_link
      begin
        io_html = open(show_page(:lang))
        html = Nokogiri::HTML(io_html)
      rescue URI::InvalidURIError => e
        # STDERR.puts e
        puts "We think we didn't parse your TV-Show's name right (#{@tv_show}). Correct us:"
        name = STDIN.gets
        @tv_show = name.strip
        retry
      end
      if io_html.status[0] == "200" && html.text.empty?
        puts "We beliewe addic7ed don't have subtitles for your episode. Check yourself:"
        puts "http://www.addic7ed.com/search.php?search=#{URI::escape(@tv_show)}"
        exit
      end

      search_result = html.xpath("//form[@action='/search.php']").children.xpath("./b")
      if search_result.any?
        if results = search_result.first.text.match(/(\d*) result.{0,1} found/)
          puts "Suddenly our bathyscaphe crashed into 'Search results page'"
          puts "They've found #{results[1]} results. Go check yourself:"
          puts "http://www.addic7ed.com/search.php?search=#{URI::escape(@tv_show)}"
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

      subtitles = subtitles.sort
      if subtitles.empty?
        puts "We didn't find your subtitles for some reason."
        puts "Try to find them manually:"
        puts "http://www.addic7ed.com/search.php?search=#{URI::escape(@tv_show)}"
        puts show_page(:lang)
        exit
      end
      puts "Found subtitles with #{subtitles.last[0]} downloads: http://www.addic7ed.com#{subtitles.last[1]}"
      subtitles.last[1]
    end

    def show_page(type)
      link = URI::escape("http://www.addic7ed.com/serie/#{@tv_show}/#{@season}/#{@episode}/")
      link += case type
      when :referer
        "addic7ed"
      when :lang
        "1"
      end
    end

  end
end