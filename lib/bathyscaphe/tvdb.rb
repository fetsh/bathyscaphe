module Bathyscaphe
  class TVDB

    TVREGEXP1 = /(.*)S([0-9]{2})E([0-9]{2}).*/i
    TVREGEXP2 = /(.*).([0-9]{1,2})x([0-9]{1,2}).*/i
    TVREGEXP3 = /(.*)Season\s*([0-9]{1,2})\s*Episode\s*([0-9]{1,2}).*/i

    TVREGEXP4 = /.*\/(.*)\/Season\s*([0-9]{1,2})\/([0-9]{1,2}).*/i
    TVREGEXP5 = /.*\/(.*)\/Season\s*([0-9]{1,2})\/.*S(?:[0-9]{2})E([0-9]{2}).*/i

    attr_accessor :name, :season, :episode

    def initialize(filename, filedir = nil)
      if filedir.nil?
        filedir = File.expand_path(File.dirname(filename))
        filename = File.basename(filename)
      end
      wholefile = File.join(filedir, filename)
      @name = @season = @episode = nil

      if md = filename.match(TVREGEXP1) || md = filename.match(TVREGEXP2) || md = filename.match(TVREGEXP3)
        @name, @season, @episode = get_from_md(md)
      end
      return unless [@name, @season, @episode].any?(&:blank?)

      if md = wholefile.match(TVREGEXP4) || md = wholefile.match(TVREGEXP5)
        @name, @season, @episode = get_from_md(md)
      end
      return unless [@name, @season, @episode].any?(&:blank?)

      if md = filedir.split("/").last.match(/(.*)Season(.*)/i)  
        @name = md[1].gsub(/[-.]+/i, ' ').gsub("'", '').strip
        @season = md[2].strip.scan(/^(\d+).*/).flatten.last.to_i.to_s
        if namemd = filename.match(/(\d*).*/)
          @episode = namemd[1].to_i.to_s
        end
      end
    end

    private

    def get_from_md(md)
      name = md[1].gsub(/[-.]+/i, " ").strip
      name = "Castle" if name =~ /Castle 2009/i
      name = "Missing (2012)" if name =~ /Missing 2012/i
      name = "Brooklyn Nine-Nine" if name =~ /Brooklyn Nine Nine/i
      name = "Doctor Who" if name =~ /Doctor Who 2005/i
      season = md[2].to_i.to_s
      episode = md[3].to_i.to_s
      return name, season, episode
    end
  end
end
