require 'helper'

describe RakeVersion::Copier do

  it "should require no arguments" do
    lambda{ RakeVersion::Copier.new }.should_not raise_error
  end

  it "should accept glob strings and regexps as arguments" do
    [
      [ 'src/**/*.js' ],
      [ /src\/.*\.sh/ ],
      [ 'src/example.js', 'src/example.rb' ],
      [ 'src/example.sh', /src\/.*\.java/, 'src/**/*.py' ]
    ].each do |args|
      lambda{ RakeVersion::Copier.new *args }.should_not raise_error
    end
  end

  it "should only accept glob strings and regexps as arguments" do
    # we do not test a hash, as it is valid to pass an options hash
    [ nil, true, false, [], Object.new, :symbol ].each do |invalid|
      lambda{ RakeVersion::Copier.new invalid }.should raise_error(RakeVersion::BadFilePattern)
    end
  end

  it "should take options" do
    lambda{ RakeVersion::Copier.new :option1 => true, :option2 => false }.should_not raise_error
  end

  it "should accept a regexp as the version option" do
    lambda{ RakeVersion::Copier.new :version => /version/ }.should_not raise_error
  end

  it "should only accept a regexp as the version option" do
    [ true, false, [], {}, Object.new, :symbol ].each do |invalid|
      lambda{ RakeVersion::Copier.new :version => invalid }.should raise_error(RakeVersion::BadVersionPattern)
    end
  end
end
