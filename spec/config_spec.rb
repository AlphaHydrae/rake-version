require 'helper'

describe RakeVersion::Config do

  before :each do
    @config = RakeVersion::Config.new
  end

  it "should be an open structure" do
    lambda{ @config.fubar = true }.should_not raise_error
  end

  describe 'Copiers' do
    
    it "should not have any copiers by default" do
      @config.copiers.should be_empty
    end

    it "should correctly create copiers" do
      copiers = [
        [],
        [ 'src/**/*.js' ],
        [ /src\/.*\.sh/ ],
        [ 'src/example.js', 'src/example.rb' ],
        [ 'src/**/*.rb', { :all => true } ]
      ]
      copiers.each do |args|
        lambda{ @config.copy *args }.should_not raise_error
      end
      @config.copiers.length.should == copiers.length
    end

    it "should create copiers with a ruby extension glob by default" do
      RakeVersion::Copier.should_receive(:new).with('src/**/*.rb')
      @config.copy
    end

    it "should return itself when creating a copier" do
      @config.copy.should === @config
    end

    it "should return a copy of its copiers array" do
      @config.copy
      @config.copiers.clear
      @config.copiers.length.should == 1
    end
  end

  describe 'Extension' do
    
    it "should have the ruby extension by default" do
      @config.extension.should == 'rb'
    end

    it "should accept alphanumerical extensions" do
      [ :rb, 'js', :sh, 'py', double('extension', :to_s => 'java') ].each do |ext|
        lambda{ @config.extension = ext }.should_not raise_error
        @config.extension.should == ext.to_s
      end
    end

    it "should not accept non-alphanumerical extensions" do
      [ nil, '.', :_, [], {}, double('fubar') ].each do |invalid|
        lambda{ @config.extension = invalid }.should raise_error(StandardError)
      end
    end
  end
end
