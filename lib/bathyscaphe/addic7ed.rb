module Bathyscaphe
  require 'nokogiri'
  require 'open-uri'
  require 'eat'
  require 'net/http'
  require 'uri'
  require 'tempfile'
  require 'fileutils'

  # Class to interact with http://addic7ed.com
  #
  # === Exaple:
  #
  #  sub = Bathyscaphe::Addic7ed.new(tv_show, season, episode)
  #  sub.save("path/to/save/subtitles")
  #
  class Addic7ed
    HOST = 'www.addic7ed.com'

    def initialize(tv_show, season = nil, episode = nil)
      if season.nil? && episode.nil?
        tv = Bathyscaphe::TVDB.new(tv_show)
        @tv_show, @season, @episode = tv.name, tv.season, tv.episode
      else
        @tv_show = tv_show
        @season = season
        @episode = episode
      end
    end

    # Fakes your identity as if you came directly from episode page
    # (otherwise addic7ed will redirect you to this episode page)
    # and downloads subtitles.
    #
    # Returns object of TempFile with subtitles.
    #
    def download
      filename = 'bathyscaphe_' + @tv_show + @season + @episode
      @temp_file = Tempfile.open(filename) do |f|
        f.write(subtitles_content)
        f
      end
    end

    def subtitles_content
      uri = URI.parse(download_link)
      headers = { 'Host' => HOST, 'Referer' => episode_link(:referer) }
      Net::HTTP.start(uri.host, uri.port) do |http|
        resp = http.get((uri.path.empty? ? '/' : uri.path), headers)
        fail(Bathyscaphe::Exceptions::Addic7edLimit) if resp.code.to_s == '302'
        return resp.body
      end
    end

    # Move downloaded subtitles to local_path
    #
    def save(local_path)
      @temp_file ||= download
      FileUtils.mv(@temp_file.path, local_path)
      File.exist?(local_path)
    end

    # Returns direct link to most updated subtitles
    # with highest downloads counter
    #
    def download_link
      html = Nokogiri::HTML(eat(episode_link(:lang)))
      fail(Bathyscaphe::Exceptions::NotFound) if html.text.empty?
      fail(Bathyscaphe::Exceptions::RedirectedToSearch) if search_page?(html)
      subtitles = scrape_subtitles(html).sort
      fail(
        Bathyscaphe::Exceptions::ScrapeFailed, "Page title: #{html.title}"
      ) if subtitles.empty?
      'http://addic7ed.com' + subtitles.last[1]
    end

    # Returns generated link to the episode page.
    #
    # === Params
    # Takes symbol as an argument:
    # *:referer* returns link for download method to fake identity.
    # *:lang* returns link with english subtitles for defined episode.
    #
    def episode_link(type = :lang)
      URI.escape(
        "http://www.addic7ed.com/serie/#{@tv_show.gsub(" ", "_")}/#{@season}/#{@episode}/"
      ) + case type
          when :referer
            'addic7ed'
          when :lang
            '1'
          else
            '1'
          end
    end

    # Returns link to search results for your tv-show name
    #
    def search_link
      "http://www.addic7ed.com/search.php?search=#{URI.escape(@tv_show)}"
    end

    private

    def search_page?(html)
      (
        search_result = html.xpath("//form[@action='/search.php']")
                        .children.xpath('./b')
      ).any? && search_result.first.text.match(/(\d*) result.{0,1} found/)
    end

    def scrape_subtitles(html)
      {}.tap do |subtitles|
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
      end
    end
  end
end
