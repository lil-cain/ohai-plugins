# Encoding: utf-8
require 'spec_helper'

rackspace = OHAI['rackspace']

describe 'Rackconnect Plugin' do
  unless rackspace.nil?
    it 'should have the rackconnect enabled key' do
      expect(rackspace['rackconnect']['enabled']).not_to be_nil
    end
  end
end
