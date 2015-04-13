# Encoding: utf-8
require 'spec_helper'

nginx = OHAI['nginx_config']
family = OHAI['platform_family']
version = OHAI['platform_version'].to_i

describe 'Nginx Config' do

  it 'should be a Mash' do
    expect(nginx).to be_a(Mash)
  end

  it 'should report configure_arguments' do
    expect(nginx['configure_arguments']).to be_a(Array)
  end

  it 'should report ssl configure_argument' do
    expect(nginx['configure_arguments']).to include('--with-http_ssl_module')
  end

  # Skip test on Debian 6 and Ubuntu 10.04 because they do
  # not include 'prefix' in `nginx -V` output.
  unless family == 'debian' && [6, 10].include?(version)
    it 'should report the prefix' do
      if family == 'debian' && [12, 7].include?(version)
        expect(nginx['prefix']).to eql('/etc/nginx')
      else
        expect(nginx['prefix']).to eql('/usr/share/nginx')
      end
    end
  end

  it 'should report configuration path' do
    expect(nginx['conf_path']).to eql('/etc/nginx/nginx.conf')
  end

end
