require 'helper'

describe RakeVersion::Manager do
  include FakeFS::SpecHelpers
  MANAGER_SAMPLE_ROOT = '/tmp'
  MANAGER_SAMPLE_VERSION = '1.2.3-beta+456'
  MANAGER_VERSION_FILE = File.join MANAGER_SAMPLE_ROOT, 'VERSION'

  before :each do
    @manager = RakeVersion::Manager.new

    @context = double root: MANAGER_SAMPLE_ROOT
    FileUtils.mkdir_p MANAGER_SAMPLE_ROOT
    File.open(MANAGER_VERSION_FILE, 'w'){ |f| f.write MANAGER_SAMPLE_VERSION }

    @version = double('version')
    @version.stub(:to_s){ MANAGER_SAMPLE_VERSION }
    @version.stub(:bump){ @version }
    @version.stub(:kind_of?){ |type| type == RakeVersion::Version }

    @copier = double('copier', :copy => nil)
    @config = double('config', :copiers => [ @copier ])
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
        v.prerelease.should == 'beta'
        v.build.should == '456'
      end
    end
  end

  it "should require a context for all operations" do
    lambda{ @manager.version }.should raise_error(RakeVersion::MissingContext)
    lambda{ @manager.set '1.2.3' }.should raise_error(RakeVersion::MissingContext)
    lambda{ @manager.bump :minor }.should raise_error(RakeVersion::MissingContext)
  end

  it "should return the correct version" do
    with_context{ |m| m.version.to_s.should == MANAGER_SAMPLE_VERSION }
  end

  it "should set the correct version" do
    with_context{ |m| m.set('1.2.3').to_s.should == '1.2.3' }
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

  it "should write the version file when bumping the version" do
    with_context{ |m| m.bump :minor }
    expect(File.read(MANAGER_VERSION_FILE)).to eq('1.3.0-beta+456')
  end

  it "should ask the context to write the version file when setting the version" do
    with_context{ |m| m.set '3.2.1-rc1' }
    expect(File.read(MANAGER_VERSION_FILE)).to eq('3.2.1-rc1')
  end

  it "should raise an error if the version file doesn't exist" do
    File.delete MANAGER_VERSION_FILE
    expect{ with_context{ |m| m.version } }.to raise_error(RakeVersion::MissingVersionFile)
  end

  describe 'Copying' do

    it "should ask the given config for its copiers" do
      @config.should_receive :copiers
      with_context{ |m| m.config = @config }
    end

    it "should ask given copiers to copy the version to sources when setting the version" do
      @manager.config = @config
      @copier.should_receive(:copy).with(kind_of(RakeVersion::Version), @context)
      with_context{ |m| m.set '1.2.3' }
    end

    [ :major, :minor, :patch ].each do |type|
      it "should ask given copiers to copy the version to sources when bumping the #{type} version" do
        @manager.config = @config
        @copier.should_receive(:copy).with(kind_of(RakeVersion::Version), @context)
        with_context{ |m| m.bump type }
      end
    end
  end
end
