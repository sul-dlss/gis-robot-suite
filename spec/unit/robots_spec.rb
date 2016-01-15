require 'spec_helper'
require 'yaml'

describe 'robots' do
  it 'can boot' do
    expect {
      require_relative '../../config/boot'
    }.not_to raise_error
  end

  # Read robots.yml to get a list of all robots in suite and verify the class exists and is a LyberCore::Robot
  context 'with all robots' do
    robots = YAML.load(File.read('config/robots.yml'))
    robots.each do |r|
      if r =~ /^(.*)_gis(.*)WF_(.*)$/
        wf = 'Gis' + Regexp.last_match(2).capitalize
        robot = Regexp.last_match(3).split('-').collect(&:capitalize).join
        klass_name = "Robots::DorRepo::#{wf}::#{robot}"
        it klass_name do
          klass = klass_name.split('::').inject(Object) { |o, c| o.const_get c }
          expect(klass.is_a? Class).to be_truthy
          expect(klass.ancestors.include? LyberCore::Robot).to be_truthy
          expect(klass.respond_to?(:perform)).to be_truthy
        end
      end
    end
  end
end
