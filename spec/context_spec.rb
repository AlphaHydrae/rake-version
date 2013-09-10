require 'helper'

describe RakeVersion::Context do
  let(:root){ '/tmp' }
  subject{ RakeVersion::Context.new(root) }

  its(:root){ should eq(root) }
end
