# Encoding: utf-8
require 'spec_helper'

php_web = OHAI['php_web']

describe 'php_web plugin' do
  it 'returns a hash of php modules' do
    expect(php_web[:modules]).to be_a(Hash)
  end

  it 'has php modules' do
    expect(php_web[:modules]['PHP Modules']).to be_a(Array)
    expect(php_web[:modules]['PHP Modules']).not_to be_empty
  end
end
