require 'spec_helper'

kernel_modules = OHAI['kernel_modules']

describe 'kernel_modules plugin' do

  it 'should be composed of hashes' do
    expect(kernel_modules['ip_tables']).to be_a(Hash)
  end

  it 'should have state Live' do
    expect(kernel_modules['ip_tables'][:state]).to eql('Live')
  end

  it 'should have dependencies' do
    expect(kernel_modules['ip_tables'][:depends]).to eql([ 'iptable_filter' ])
  end

end
  
