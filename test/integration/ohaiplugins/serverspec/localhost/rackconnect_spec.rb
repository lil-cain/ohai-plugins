# Encoding: utf-8
require 'spec_helper'

rackspace = OHAI['rackspace']
rackconnect = OHAI['rackspace']['rackconnect']

describe 'Rackconnect Plugin' do
  unless rackspace.nil?
    it 'should have the rackconnect enabled key' do
      expect(rackconnect['enabled']).to exist
    end
  end
end
