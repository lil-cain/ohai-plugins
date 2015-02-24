require 'spec_helper'

block_devices = OHAI['block_devices']

describe 'Block Devices plugin' do
  it 'should be a Mash' do
    expect(block_devices).to be_a(Mash)
  end

  it 'should have a type for each value' do
    bd_hash = block_devices.to_hash
    bd_hash.keys.each do |key|
      expect(bd_hash[key]['TYPE']).not_to be_empty
    end
  end

  it 'should have a UUID for each value' do
    bd_hash = block_devices.to_hash
    bd_hash.keys.each do |key|
      expect(bd_hash[key]['UUID']).not_to be_empty
    end
  end
end
