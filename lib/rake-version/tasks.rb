
module RakeVersion

  class Tasks < ::Rake::TaskLib

    def initialize &block
      @manager = RakeVersion::Manager.new
      yield @manager if block_given?
      define
    end

    def define
      desc 'Show the current version'
      task :version do |t|
        puts @manager.version.to_s
      end

      namespace :version do

        desc 'Set the version (e.g. rake version:set[1.2.3])'
        task :set, :value do |t, args|
          puts @manager.set(args.value.to_s)
        end

        namespace :bump do

          [ :major, :minor, :patch ].each do |type|
            task type do |t|
              puts @manager.bump(type).to_s
            end
          end
        end
      end
    end

    def task *args, &block
      super *args do |t, args|
        @manager.with_context context(t) do |m|
          yield t, args if block_given?
        end
      end
    end

    private

    def context task
      RakeVersion::Context.new task
    end
  end
end
