require 'helper'
require 'rake'

describe "Rake Extension" do

  it "should add a method to remove tasks" do

    Rake::Task.define_task('foo'){}

    expect(Rake::Task.task_defined?('foo')).to be_true
    Rake.application.remove_task 'foo'
    expect(Rake::Task.task_defined?('foo')).to be_false
  end
end
