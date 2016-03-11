require 'helper'

describe 'Version' do
  subject{ RakeVersion::VERSION }
  it{ should eq(File.read(File.join(File.dirname(__FILE__), '..', 'VERSION'))) }
end

describe RakeVersion::Version do

  it "should build a correct version object when initialized" do
    RakeVersion::Version.new.tap do |v|
      expect(v.major).to eq(0)
      expect(v.minor).to eq(0)
      expect(v.patch).to eq(0)
      expect(v.prerelease).to be_nil
      expect(v.build).to be_nil
    end
  end

  it "should build a correct version object when built from a string" do
    RakeVersion::Version.new.from_s('1.2.3-beta+456').tap do |v|
      expect(v.major).to eq(1)
      expect(v.minor).to eq(2)
      expect(v.patch).to eq(3)
      expect(v.prerelease).to eq('beta')
      expect(v.build).to eq('456')
    end
  end

  it "should build the correct version string when built from a string" do
    [ '1.2.3', '2.3.4+567', '3.4.5-beta', '5.6.7-beta-custom', '8.9.0-rc1+1234' ].each do |v|
      expect(RakeVersion::Version.new.from_s(v).to_s).to eq(v)
    end
  end

  it "should raise an error when built from invalid version strings" do
    [ '1', '2.3', 'a.b.c.d.e', 'asd', nil, true, false, [], {}, '' ].each do |invalid|
      expect{ RakeVersion::Version.new.from_s invalid }.to raise_error(RakeVersion::BadVersionString)
    end
  end

  describe 'Bumping' do

    before :each do
      @version1 = RakeVersion::Version.new.from_s '1.2.3-beta+123'
      @version2 = RakeVersion::Version.new.from_s '2.3.4-alpha+456'
      @version3 = RakeVersion::Version.new.from_s '3.4.5-gamma+789'
    end

    it "should correctly bump the major version" do
      expect(@version1.bump(:major).to_s).to eq('2.0.0-beta+123')
      expect(@version2.bump(:major).to_s).to eq('3.0.0-alpha+456')
      expect(@version3.bump(:major).to_s).to eq('4.0.0-gamma+789')
    end

    it "should correctly bump the minor version" do
      expect(@version1.bump(:minor).to_s).to eq('1.3.0-beta+123')
      expect(@version2.bump(:minor).to_s).to eq('2.4.0-alpha+456')
      expect(@version3.bump(:minor).to_s).to eq('3.5.0-gamma+789')
    end

    it "should correctly bump the patch version" do
      expect(@version1.bump(:patch).to_s).to eq('1.2.4-beta+123')
      expect(@version2.bump(:patch).to_s).to eq('2.3.5-alpha+456')
      expect(@version3.bump(:patch).to_s).to eq('3.4.6-gamma+789')
    end

    it "should not accept unknown bump types" do
      [ nil, true, false, '', 'asd', :build, :unknown, :Major, [], {} ].each do |invalid|
        expect{ @version1.bump invalid }.to raise_error(RakeVersion::BadBumpType)
      end
    end
  end
end
