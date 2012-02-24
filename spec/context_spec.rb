require 'helper'

describe RakeVersion::Context do
  CONTEXT_SAMPLE_ROOT = '/tmp'

  before :each do
    
    @application = double('application')
    @application.stub(:original_dir){ CONTEXT_SAMPLE_ROOT }

    @task = double('task')
    @task.stub(:application){ @application }
  end

  it "should return the application directory for the given rake task" do
    RakeVersion::Context.new(@task).root.should == CONTEXT_SAMPLE_ROOT
  end

  it "should successfully read file contents" do

    filename = 'foo'
    contents = 'bar'

    File.stub(:open) do |file,mode|
      if mode == 'r' and file == filename
        double('file').tap{ |f| f.stub(:read){ contents } }
      end
    end

    RakeVersion::Context.new(@task).read(filename).should == contents
  end

  it "should ask File to write file contents" do

    filename = 'foo'
    contents = 'bar'

    file = double('file')
    file.stub(:write)

    File.stub(:open) do |f,mode|
      raise 'bug' unless f == filename and mode == 'w'
    end.and_yield file

    file.should_receive(:write).with(contents)
    RakeVersion::Context.new(@task).write(filename, contents)
  end
end
