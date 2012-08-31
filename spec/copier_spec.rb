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
    lambda{ RakeVersion::Copier.new 'version' => /version/ }.should_not raise_error
  end

  it "should only accept a regexp as the version option" do
    [ true, false, [], {}, Object.new, :symbol ].each do |invalid|
      lambda{ RakeVersion::Copier.new :version => invalid }.should raise_error(RakeVersion::BadVersionPattern)
      lambda{ RakeVersion::Copier.new 'version' => invalid }.should raise_error(RakeVersion::BadVersionPattern)
    end
  end

  describe 'Copying' do
    COPIER_SAMPLE_ROOT = '/tmp'
    COPIER_SAMPLE_VERSION = '7.8.9'
    COPIER_SAMPLE_FILES = {
      '/tmp/src/example.rb' => "#\n# example v1.2.3\n#\n\nputs 'Hello World!'",
      '/tmp/src/example.js' => "/*\n * example v2.3.4\n */\n\nconsole.log('Hello World!');\n// This is example v2.3.4",
      '/tmp/src/script/sub-example.sh' => "#\n# example v3.4.5\n#\n\necho 'Hello World!'",
      '/tmp/src/script/sub-example.rb' => "#\n# example v4.5.6\n#\n\nputs 'Hello World!'\n# This is example v4.5.6",
      '/tmp/lib/example.java' => "/**\n * example v5.6.7\n */\n\n// not yet implemented",
      '/tmp/README' => "not\na\nsource\nfile"
    }

    before :each do
      
      @version = double('version', :to_s => COPIER_SAMPLE_VERSION)
      @context = double('context', :root => COPIER_SAMPLE_ROOT)

      File.stub(:file?) do |file|
        !!COPIER_SAMPLE_FILES[file]
      end

      stub = Find.stub(:find)
      COPIER_SAMPLE_FILES.keys.each do |k|
        stub.and_yield k
      end

      Dir.stub(:chdir)
      Dir.stub(:glob) do |pattern|
        COPIER_SAMPLE_FILES.keys.select do |k|
          m = pattern.match /^\*\*\/\*\.([a-z]+)$/
          m and k.match(Regexp.new("\\.#{m[1]}$"))
        end
      end
    end

    def mock_file file
      contents = COPIER_SAMPLE_FILES[file] ? COPIER_SAMPLE_FILES[file].dup : nil
      double("file #{file}", :read => contents, :rewind => nil, :write => nil)
    end

    it "should copy the version to ruby files with a glob string" do

      filename1, filename2 = '/tmp/src/example.rb', '/tmp/src/script/sub-example.rb'
      file1, file2 = mock_file(filename1), mock_file(filename2)
      File.stub(:open).and_yield(file1).and_yield(file2)

      copier = RakeVersion::Copier.new '**/*.rb'

      @version.should_receive(:to_s)
      @context.should_receive(:root)
      File.should_receive(:open).with(filename1, 'r+')
      File.should_receive(:open).with(filename2, 'r+')
      file1.should_receive(:write).with(COPIER_SAMPLE_FILES[filename1].sub(/1\.2\.3/, '7.8.9'))
      file2.should_receive(:write).with(COPIER_SAMPLE_FILES[filename2].sub(/4\.5\.6/, '7.8.9'))

      copier.copy @version, @context
    end

    it "should copy the version to javascript files with a regexp" do

      filename = '/tmp/src/example.js'
      file = mock_file filename
      File.stub(:open).and_yield(file)

      copier = RakeVersion::Copier.new /\.js$/

      @version.should_receive(:to_s)
      @context.should_receive(:root)
      File.should_receive(:open).with(filename, 'r+')
      file.should_receive(:write).with(COPIER_SAMPLE_FILES[filename].sub(/2\.3\.4/, '7.8.9'))

      copier.copy @version, @context
    end

    it "should copy the version to files identified by several glob strings and regexps" do

      filename1, filename2 = '/tmp/src/script/sub-example.sh', '/tmp/lib/example.java'
      file1, file2 = mock_file(filename1), mock_file(filename2)
      File.stub(:open).and_yield(file1).and_yield(file2)

      copier = RakeVersion::Copier.new '**/*.sh', /lib/

      @version.should_receive(:to_s)
      @context.should_receive(:root)
      File.should_receive(:open).with(filename1, 'r+')
      File.should_receive(:open).with(filename2, 'r+')
      file1.should_receive(:write).with(COPIER_SAMPLE_FILES[filename1].sub(/3\.4\.5/, '7.8.9'))
      file2.should_receive(:write).with(COPIER_SAMPLE_FILES[filename2].sub(/5\.6\.7/, '7.8.9'))

      copier.copy @version, @context
    end

    it "should not modify files that do not match the version pattern" do
      
      filename = '/tmp/README'
      file = mock_file filename
      File.stub(:open).and_yield(file)

      copier = RakeVersion::Copier.new /README/

      @version.should_not_receive(:to_s)
      @context.should_receive(:root)
      File.should_receive(:open).with(filename, 'r+')
      file.should_not_receive(:write)

      copier.copy @version, @context
    end

    it "should replace all occurences of the version pattern if specified" do
    
      filename1, filename2 = '/tmp/src/example.js', '/tmp/src/script/sub-example.rb'
      file1, file2 = mock_file(filename1), mock_file(filename2)
      File.stub(:open).and_yield(file1).and_yield(file2)

      copier = RakeVersion::Copier.new /\.js$/, /sub.*\.rb$/, :all => true

      @version.should_receive(:to_s)
      @context.should_receive(:root)
      File.should_receive(:open).with(filename1, 'r+')
      File.should_receive(:open).with(filename2, 'r+')
      file1.should_receive(:write).with(COPIER_SAMPLE_FILES[filename1].gsub(/2\.3\.4/, '7.8.9'))
      file2.should_receive(:write).with(COPIER_SAMPLE_FILES[filename2].gsub(/4\.5\.6/, '7.8.9'))

      copier.copy @version, @context
    end

    it "should replace the given version pattern" do
      
      filename = '/tmp/src/example.js'
      file = mock_file filename
      File.stub(:open).and_yield(file)

      copier = RakeVersion::Copier.new '**/*.js', :version => /v\d+\.\d+\.\d+/

      @version.should_receive(:to_s)
      @context.should_receive(:root)
      File.should_receive(:open).with(filename, 'r+')
      file.should_receive(:write).with(COPIER_SAMPLE_FILES[filename].sub(/v2\.3\.4/, '7.8.9'))

      copier.copy @version, @context
    end
  end
end
