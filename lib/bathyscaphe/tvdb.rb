module Bathyscaphe
  class TVDB

    TVREGEXP1 = /(.*)S([0-9]{2})E([0-9]{2}).*/i
    TVREGEXP2 = /(.*).([0-9]{1,2})x([0-9]{1,2}).*/i

    attr_accessor :name, :season, :episode

    def initialize filename
      if md = filename.match(TVREGEXP1) || md = filename.match(TVREGEXP2)
        @name = md[1].gsub(".", " ").strip
        @name = "Castle" if @name =~ /Castle 2009/i
        @name = "Missing (2012)" if @name =~ /Missing 2012/i
        @season = md[2].to_i.to_s
        @episode = md[3].to_i.to_s
      else
        raise("Cant't parse filename")
      end
    end
  end
end