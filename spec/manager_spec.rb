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
    allow(@version).to receive(:to_s){ MANAGER_SAMPLE_VERSION }
    allow(@version).to receive(:bump){ @version }
    allow(@version).to receive(:kind_of?){ |type| type == RakeVersion::Version }

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
        expect(v).to be_a_kind_of(RakeVersion::Version)
        expect(v.major).to eq(1)
        expect(v.minor).to eq(2)
        expect(v.patch).to eq(3)
        expect(v.prerelease).to eq('beta')
        expect(v.build).to eq('456')
      end
    end
  end

  it "should require a context for all operations" do
    expect{ @manager.version }.to raise_error(RakeVersion::MissingContext)
    expect{ @manager.set '1.2.3' }.to raise_error(RakeVersion::MissingContext)
    expect{ @manager.bump :minor }.to raise_error(RakeVersion::MissingContext)
  end

  it "should return the correct version" do
    with_context{ |m| expect(m.version.to_s).to eq(MANAGER_SAMPLE_VERSION) }
  end

  it "should set the correct version" do
    with_context{ |m| expect(m.set('1.2.3').to_s).to eq('1.2.3') }
  end

  it "should ask for the context root" do
    expect(@context).to receive :root
    with_context{ |m| m.version }
  end

  it "should ask the version to bump itself" do
    allow(@manager).to receive(:version){ @version }
    [ :major, :minor, :patch ].each do |type|
      expect(@version).to receive(:bump).with(type)
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
      expect(@config).to receive :copiers
      with_context{ |m| m.config = @config }
    end

    it "should ask given copiers to copy the version to sources when setting the version" do
      @manager.config = @config
      expect(@copier).to receive(:copy).with(kind_of(RakeVersion::Version), @context)
      with_context{ |m| m.set '1.2.3' }
    end

    [ :major, :minor, :patch ].each do |type|
      it "should ask given copiers to copy the version to sources when bumping the #{type} version" do
        @manager.config = @config
        expect(@copier).to receive(:copy).with(kind_of(RakeVersion::Version), @context)
        with_context{ |m| m.bump type }
      end
    end
  end
end
