
require 'helper'

describe RakeVersion::Manager do
  SAMPLE_ROOT = '/tmp'
  SAMPLE_VERSION = '1.2.3.456-beta-custom'

  before :each do
    @manager = RakeVersion::Manager.new

    @context = double('context')
    @context.stub(:root){ SAMPLE_ROOT }
    @context.stub(:read){ SAMPLE_VERSION }
    @context.stub(:write){}
    @context.stub(:kind_of?){ |type| type == RakeVersion::Context }

    @version = double('version')
    @version.stub(:to_s){ SAMPLE_VERSION }
    @version.stub(:bump){ @version }
    @version.stub(:kind_of?){ |type| type == RakeVersion::Version }
  end

  def with_context &block
    @manager.with_context @context do |m|
      yield m if block_given?
    end
  end

  it "should return a version object" do
    with_context do |m|
      m.version.tap do |v|
        v.should be_a_kind_of(RakeVersion::Version)
        v.major.should == 1
        v.minor.should == 2
        v.patch.should == 3
        v.build.should == 456
        v.tags.should be_a_kind_of(Array)
        v.tags.length.should == 2
        v.tags[0].should == 'beta'
        v.tags[1].should == 'custom'
      end
    end
  end

  it "should require a context for all operations" do
    lambda{ @manager.version }.should raise_error(RakeVersion::MissingContext)
    lambda{ @manager.set '1.2.3' }.should raise_error(RakeVersion::MissingContext)
    lambda{ @manager.bump :minor }.should raise_error(RakeVersion::MissingContext)
  end

  it "should return the correct version" do
    with_context{ |m| m.version.to_s.should == SAMPLE_VERSION }
  end

  it "should ask for the context root" do
    @context.should_receive :root
    with_context{ |m| m.version }
  end

  it "should ask the version to bump itself" do
    @manager.stub(:version){ @version }
    [ :major, :minor, :patch ].each do |type|
      @version.should_receive(:bump).with(type)
      with_context{ |m| m.bump type }
    end
  end

  it "should ask the context to read the version file" do
    @context.should_receive(:read).with(File.join(SAMPLE_ROOT, 'VERSION'))
    with_context{ |m| m.version }
  end

  it "should ask the context to write the version file when bumping the version" do
    @context.should_receive(:write).with(File.join(SAMPLE_ROOT, 'VERSION'), '1.3.0.456-beta-custom')
    with_context{ |m| m.bump :minor }
  end

  it "should ask the context to write the version file when setting the version" do
    @context.should_receive(:write).with(File.join(SAMPLE_ROOT, 'VERSION'), SAMPLE_VERSION)
    with_context{ |m| m.set SAMPLE_VERSION }
  end

  it "should only accept the right type of context" do
    [ nil, true, false, 2, 'bad', :bad, [], {}, @version ].each do |invalid|
      lambda{ @manager.with_context invalid }.should raise_error(RakeVersion::BadContext)
    end
  end
end
