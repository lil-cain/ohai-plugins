require 'spec_helper'

sysctl = OHAI['sysctl']

describe "sysctl Plugin" do
  it 'should return a number of keys from the system' do
    # TODO: Test could be refined if we determine some specific data wwe hope to see
    # For now we're just testing that a bunch of data got returned
    expect(sysctl.keys.size).to be > 10
  end
end
