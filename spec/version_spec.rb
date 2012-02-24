require 'helper'

describe RakeVersion::Version do

  it "should build a correct version object when initialized" do
    RakeVersion::Version.new.tap do |v|
      v.major.should == 0
      v.minor.should == 0
      v.patch.should == 0
      v.build.should be_nil
      v.tags.should be_a_kind_of(Array)
      v.tags.length.should == 0
    end
  end

  it "should build a correct version object when built from a string" do
    RakeVersion::Version.new.from_s('1.2.3.456-beta-custom').tap do |v|
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

  it "should build the correct version string when built from a string" do
    [ '1.2.3', '2.3.4.567', '3.4.5.678-beta', '5.6.7.890-beta-custom' ].each do |v|
      RakeVersion::Version.new.from_s(v).to_s.should == v
    end
  end

  it "should raise an error when built from invalid version strings" do
    [ '1', '2.3', '4.5.6.7.8', 'asd', nil, true, false, [], {}, '' ].each do |invalid|
      lambda{ RakeVersion::Version.new.from_s invalid }.should raise_error(RakeVersion::BadVersionString)
    end
  end

  describe 'Bumping' do

    before :each do
      @version1 = RakeVersion::Version.new.from_s '1.2.3.456-beta-custom'
      @version2 = RakeVersion::Version.new.from_s '2.3.4.567-alpha-customer'
      @version3 = RakeVersion::Version.new.from_s '3.4.5.678-gamma-prod'
    end

    it "should correctly bump the major version" do
      @version1.bump(:major).to_s.should == '2.0.0.456-beta-custom'
      @version2.bump(:major).to_s.should == '3.0.0.567-alpha-customer'
      @version3.bump(:major).to_s.should == '4.0.0.678-gamma-prod'
    end

    it "should correctly bump the minor version" do
      @version1.bump(:minor).to_s.should == '1.3.0.456-beta-custom'
      @version2.bump(:minor).to_s.should == '2.4.0.567-alpha-customer'
      @version3.bump(:minor).to_s.should == '3.5.0.678-gamma-prod'
    end

    it "should correctly bump the patch version" do
      @version1.bump(:patch).to_s.should == '1.2.4.456-beta-custom'
      @version2.bump(:patch).to_s.should == '2.3.5.567-alpha-customer'
      @version3.bump(:patch).to_s.should == '3.4.6.678-gamma-prod'
    end

    it "should not accept unknown bump types" do
      [ nil, true, false, '', 'asd', :build, :unknown, :Major, [], {} ].each do |invalid|
        lambda{ @version1.bump invalid }.should raise_error(RakeVersion::BadBumpType)
      end
    end
  end
end
