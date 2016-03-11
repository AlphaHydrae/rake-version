require 'helper'

describe RakeVersion::Copier do
  include FakeFS::SpecHelpers

  it "should require no arguments" do
    expect{ RakeVersion::Copier.new }.not_to raise_error
  end

  it "should accept glob strings and regexps as arguments" do
    [
      [ 'src/**/*.js' ],
      [ /src\/.*\.sh/ ],
      [ 'src/example.js', 'src/example.rb' ],
      [ 'src/example.sh', /src\/.*\.java/, 'src/**/*.py' ]
    ].each do |args|
      expect{ RakeVersion::Copier.new *args }.not_to raise_error
    end
  end

  it "should only accept glob strings and regexps as arguments" do
    # we do not test a hash, as it is valid to pass an options hash
    [ nil, true, false, [], Object.new, :symbol ].each do |invalid|
      expect{ RakeVersion::Copier.new invalid }.to raise_error(RakeVersion::BadFilePattern)
    end
  end

  it "should take options" do
    expect{ RakeVersion::Copier.new :option1 => true, :option2 => false }.not_to raise_error
  end

  describe 'Copying' do
    let(:sample_root){ '/tmp' }
    let(:sample_version){ '7.8.9' }
    let :sample_files do
      {
        '/tmp/src/example.rb' => "#\n# example v1.2.3\n#\n\nputs 'Hello World!'",
        '/tmp/src/example.js' => "/*\n * example v2.3.4\n */\n\nconsole.log('Hello World!');\n// This is example v2.3.4",
        '/tmp/src/script/sub-example.sh' => "#\n# example v3.4.5\n#\n\necho 'Hello World!'",
        '/tmp/src/script/sub-example.rb' => "#\n# example v4.5.6\n#\n\nputs 'Hello World!'\n# This is example v4.5.6",
        '/tmp/lib/example.java' => "/**\n * example v5.6.7\n */\n\n// not yet implemented",
        '/tmp/README' => "not\na\nsource\nfile"
      }
    end
    let(:version){ double to_s: sample_version }
    let(:context){ double root: sample_root }

    before :each do
      sample_files.each_pair do |file,contents|
        FileUtils.mkdir_p File.dirname(file)
        File.open(file, 'w'){ |f| f.write contents }
      end
    end

    def read file
      File.read file
    end

    def copy *args
      RakeVersion::Copier.new(*args).copy version, context
    end

    it "should copy the version to ruby files with a glob string" do
      f1, f2 = '/tmp/src/example.rb', '/tmp/src/script/sub-example.rb'
      copy '**/*.rb'
      expect(read(f1)).to eq(sample_files[f1].sub(/1\.2\.3/, '7.8.9'))
      expect(read(f2)).to eq(sample_files[f2].sub(/4\.5\.6/, '7.8.9'))
    end

    it "should copy the version to javascript files with a regexp" do
      f = '/tmp/src/example.js'
      copy /\.js$/
      expect(read(f)).to eq(sample_files[f].sub(/2\.3\.4/, '7.8.9'))
    end

    it "should copy the version to files identified by several glob strings and regexps" do
      f1, f2 = '/tmp/src/script/sub-example.sh', '/tmp/lib/example.java'
      copy '**/*.sh', /lib/
      expect(read(f1)).to eq(sample_files[f1].sub(/3\.4\.5/, '7.8.9'))
      expect(read(f2)).to eq(sample_files[f2].sub(/5\.6\.7/, '7.8.9'))
    end

    it "should not modify files that do not match the version pattern" do
      f = '/tmp/README'
      copy /README/
      expect(read(f)).to eq(sample_files[f])
    end

    it "should replace all occurences of the version pattern if specified" do
      f1, f2 = '/tmp/src/example.js', '/tmp/src/script/sub-example.rb'
      copy /\.js$/, /sub.*\.rb$/, all: true
      expect(read(f1)).to eq(sample_files[f1].gsub(/2\.3\.4/, '7.8.9'))
      expect(read(f2)).to eq(sample_files[f2].gsub(/4\.5\.6/, '7.8.9'))
    end
  end
end
