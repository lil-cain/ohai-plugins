require 'spec_helper'

unless OHAI['platform_family'] == 'rhel' && OHAI['platform_version'].to_i == 5
  ip_tables = OHAI['ip_tables']

  describe 'Ip_tables Plugin' do

    it 'should be a Mash' do
      expect(ip_tables).to be_a(Mash)
    end

    it 'should contain rules' do
      expect(ip_tables[0]).not_to be_empty
    end

  end
end
