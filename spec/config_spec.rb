require 'helper'

describe RakeVersion::Config do

  before :each do
    @config = RakeVersion::Config.new
  end

  describe 'Copiers' do

    it "should not have any copiers by default" do
      expect(@config.copiers).to be_empty
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
        expect{ @config.copy *args }.not_to raise_error
      end
      expect(@config.copiers.length).to eq(copiers.length)
    end

    it "should create copiers with a ruby extension glob by default" do
      expect(RakeVersion::Copier).to receive(:new).with('src/**/*.rb')
      @config.copy
    end

    it "should return itself when creating a copier" do
      expect(@config.copy).to be(@config)
    end

    it "should return a copy of its copiers array" do
      @config.copy
      @config.copiers.clear
      expect(@config.copiers.length).to eq(1)
    end
  end

  describe 'Extension' do

    it "should have the ruby extension by default" do
      expect(@config.extension).to eq('rb')
    end

    it "should accept alphanumerical extensions" do
      [ :rb, 'js', :sh, 'py', double('extension', :to_s => 'java') ].each do |ext|
        expect{ @config.extension = ext }.not_to raise_error
        expect(@config.extension).to eq(ext.to_s)
      end
    end

    it "should not accept non-alphanumerical extensions" do
      [ nil, '.', :_, [], {}, double('fubar') ].each do |invalid|
        expect{ @config.extension = invalid }.to raise_error(StandardError)
      end
    end
  end
end
