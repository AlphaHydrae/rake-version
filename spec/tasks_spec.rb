require 'helper'

describe RakeVersion::Tasks do
  include FakeFS::SpecHelpers
  TASKS_SAMPLE_VERSION = '1.2.3'

  before :each do

    Rake::Task.clear

    @version = double
    @version.stub(:to_s){ TASKS_SAMPLE_VERSION }

    @manager = double
    @manager.stub(:version){ @version }
    @manager.stub(:set){ @version }
    @manager.stub(:bump){ @version }
    @manager.stub(:with_context).and_yield(@manager).and_return(@manager)
    @manager.stub(:config=)

    RakeVersion::Manager.stub(:new){ @manager }
    Rake.application.stub remove_task: nil
  end

  context "automatic clearing" do
    let(:task_names){ %w(version version:bump:major version:bump:minor version:bump:patch version:set) }
    let(:other_task_names){ %w(version:write) }
    let(:all_task_names){ task_names + other_task_names }
    let(:rake_task_double){ double clear: nil }

    it "should not fail when no version tasks exist" do
      expect{ RakeVersion::Tasks.new }.not_to raise_error
    end

    context "with existing tasks" do

      it "should clear existing version tasks" do
        all_task_names.each{ |task_name| expect(Rake.application).to receive(:remove_task).with(task_name).ordered }
        expect(Rake.application).not_to receive(:remove_task).ordered
        RakeVersion::Tasks.new
      end

      it "should only clear rake-version tasks in strict mode" do
        task_names.each{ |task_name| expect(Rake.application).to receive(:remove_task).with(task_name).ordered }
        expect(Rake.application).not_to receive(:remove_task).ordered
        RakeVersion::Tasks.new clear_strict: true
      end

      it "should not clear existing version tasks if disabled" do
        expect(Rake.application).not_to receive(:remove_task)
        RakeVersion::Tasks.new clear: false
      end
    end
  end

  context "when initialized" do

    before :each do
      RakeVersion::Tasks.new
    end

    it "should define all tasks" do
      %w( version version:set version:bump:major version:bump:minor version:bump:patch ).each do |name|
        Rake::Task[name].should be_a_kind_of(Rake::Task)
      end
    end

    it "should receive a context whose root is the application directory of the rake task" do
      @manager.should_receive :with_context do |context|
        expect(context.root).to eq(Rake.application.original_dir)
      end.and_yield(@manager)
      expect_success(TASKS_SAMPLE_VERSION){ Rake::Task['version'].execute }
    end

    it "should ask the manager to return the current version" do
      @manager.should_receive(:version)
      expect_success(TASKS_SAMPLE_VERSION){ Rake::Task['version'].execute }
    end

    it "should ask the manager to set the version" do
      @manager.should_receive(:set).with(kind_of(String))
      expect_success(TASKS_SAMPLE_VERSION){ Rake::Task['version:set'].invoke TASKS_SAMPLE_VERSION }
    end

    [ :major, :minor, :patch ].each do |type|
      it "should ask the manager to bump the #{type} version" do
        @manager.should_receive(:bump).with(type)
        expect_success(TASKS_SAMPLE_VERSION){ Rake::Task["version:bump:#{type}"].execute }
      end
    end

    it "should print a warning on stderr if the version file doesn't exist" do
      @manager.stub(:version){ raise RakeVersion::MissingVersionFile.new('fubar') }
      expect_failure(/fubar/){ Rake::Task['version'].execute }
    end

    it "should raise an error if the version file doesn't exist and trace is enabled" do
      Rake.application.options.stub trace: true
      @manager.stub(:version){ raise RakeVersion::MissingVersionFile.new('fubar') }
      expect_error(RakeVersion::MissingVersionFile){ Rake::Task['version'].execute }
    end
  end
  
  private

  def expect_success output
    stdout, stderr = StringIO.new, StringIO.new
    $stdout, $stderr = stdout, stderr
    expect{ yield }.not_to raise_error
    $stdout, $stderr = STDOUT, STDERR
    expect(stdout.string.strip).to match(output)
    expect(stderr.string).to be_empty
  end

  def expect_failure message, code = 1

    stderr = StringIO.new
    $stderr = stderr
    expect{ yield }.to raise_error(SystemExit){ |e| expect(e.status).to eq(code) }
    $stderr = STDERR

    if message.kind_of? Regexp
      expect(stderr.string.strip).to match(message)
    end
  end

  def expect_error type
    stdout, stderr = StringIO.new, StringIO.new
    $stdout, $stderr = stdout, stderr
    expect{ yield }.to raise_error(type)
    $stdout, $stderr = STDOUT, STDERR
  end
end
