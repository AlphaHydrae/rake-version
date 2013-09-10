
module RakeVersion

  class Config

    attr_reader :extension

    def initialize
      super
      @copiers = []
      @extension = 'rb'
    end

    def copy *args
      args.unshift "src/**/*.#{@extension}" if args.empty?
      @copiers << Copier.new(*args)
      self
    end

    def copiers
      Array.new @copiers
    end

    def extension= extension
      raise "Expected extension to be alphanumerical, got #{extension.inspect}." unless extension.respond_to?(:to_s) and extension.to_s.match(/^[a-z0-9]+$/i)
      @extension = extension.to_s
    end
  end
end
