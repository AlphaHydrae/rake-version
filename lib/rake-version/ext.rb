
Rake::TaskManager.class_eval do

  def remove_task task_name
    @tasks.delete task_name.to_s
  end
end
