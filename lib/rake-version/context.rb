
module RakeVersion

  class Context
  
    def initialize task
      @task = task
    end

    def root
      @task.application.original_dir
    end
  end
end
