
module RakeVersion

  class Context
  
    def initialize task
      @task = task
    end

    def root
      File.expand_path @task.application.original_dir
    end

    def read file
      File.open(file, 'r').read
    end

    def write file, contents
      File.open(file, 'w'){ |f| f.write contents }
    end
  end
end
