
module RakeVersion

  class Config < Hash

    def initialize
      @copiers = []
    end

    def copy file_pattern, options = {}
      @copiers << Copier.new(file_pattern, options)
    end

    def copiers
      Array.new @copiers
    end
  end
end
