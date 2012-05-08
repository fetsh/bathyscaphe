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
      html = Nokogiri::HTML(open(show_page(:lang)))
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