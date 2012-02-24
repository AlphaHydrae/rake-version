require 'helper'
require 'active_support/core_ext/kernel/reporting'

describe RakeVersion::Tasks do
  TASKS_SAMPLE_VERSION = '1.2.3'

  before :each do

    @version = double('version')
    @version.stub(:to_s){ TASKS_SAMPLE_VERSION }

    @manager = double('manager')
    @manager.stub(:version){ @version }
    @manager.stub(:set){ @version }
    @manager.stub(:bump){ @version }
    @manager.stub(:with_context).and_yield(@manager)

    RakeVersion::Manager.stub(:new){ @manager }
    RakeVersion::Tasks.new
  end

  after :each do
    Rake::Task.clear
  end

  def silence &block
    silence_stream(STDOUT) do
      silence_stream(STDERR) do
        yield if block_given?
      end
    end
  end

  it "should define all tasks" do
    %w( version version:set version:bump:major version:bump:minor version:bump:patch ).each do |name|
      Rake::Task[name].should be_a_kind_of(Rake::Task)
    end
  end

  it "should ask the manager to return the current version" do
    @manager.should_receive(:version)
    silence{ Rake::Task['version'].execute }
  end

  it "should ask the manager to set the version" do
    @manager.should_receive(:set).with(kind_of(String))
    silence{ Rake::Task['version:set'].invoke TASKS_SAMPLE_VERSION }
  end

  [ :major, :minor, :patch ].each do |type|
    it "should ask the manager to bump the #{type} version" do
      @manager.should_receive(:bump).with(type)
      silence{ Rake::Task["version:bump:#{type}"].execute }
    end
  end
end
