require 'spec_helper'

describe 'booting' do
  it 'can boot' do
    expect {
      require './config/boot'
    }.not_to raise_error
  end
end
