require 'ostruct'

module RakeVersion

  class Config < OpenStruct

    def initialize
      @copiers = []
      @extension = :rb
    end

    def copy *args
      options = args.extract_options!
      args.unshift "src/**/*.#{@extension}" if args.blank?
      args << options
      @copiers << Copier.new(*args)
    end

    def copiers
      Array.new @copiers
    end

    def extension= extension
      raise "Expected extension to be alphanumerical, got #{extension.inspect}." unless extension.respond_to?(:to_s) and extension.to_s.match(/^[a-z0-9]+$/i)
      @extension = extension.to_s.downcase
    end
  end
end
