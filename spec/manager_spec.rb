
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
    @version.stub(:kind_of?){ |type| type == RakeVersion::Version }
  end

  it "should return a version object" do
    @manager.version(@context).tap do |v|
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

  it "should return the correct version" do
    @manager.version(@context).to_s.should == SAMPLE_VERSION
  end

  it "should ask for the context root" do
    @context.should_receive :root
    @manager.version @context
  end

  it "should ask the context to read the version file" do
    @context.should_receive(:read).with(File.join(SAMPLE_ROOT, 'VERSION'))
    @manager.version @context
  end

  it "should ask the context to write the version file" do
    @context.should_receive(:write).with(File.join(SAMPLE_ROOT, 'VERSION'), SAMPLE_VERSION)
    @manager.save @version, @context
  end

  it "should only accept the right type of context" do
    [ nil, true, false, 2, 'bad', :bad, [], {}, @version ].each do |invalid|
      lambda{ @manager.version invalid }.should raise_error(RakeVersion::BadContext)
      lambda{ @manager.bump :major, invalid }.should raise_error(RakeVersion::BadContext)
      lambda{ @manager.save @version, invalid }.should raise_error(RakeVersion::BadContext)
    end
  end

  it "should only accept the right type of version" do
    [ nil, true, false, 2, 'bad', :bad, [], {}, @context ].each do |invalid|
      lambda{ @manager.save invalid, @context }.should raise_error(RakeVersion::BadVersion)
    end
  end
end
