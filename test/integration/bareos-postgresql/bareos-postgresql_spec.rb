# encoding: utf-8

control 'Bareos source list' do
  impact 0.6
  title 'Bareos source list'
  desc 'Ensures bareos source is installed'
  describe file('/etc/apt/sources.list.d/bareos.list') do
    its('content') { should match %r{deb http://download.bareos.org/bareos/release/latest/xUbuntu_16.04 ./} }
  end
end

control 'Bareos packages' do
  impact 0.7
  title 'Verify bareos packages'
  desc 'Ensures bareos packages are installed with the right version'
  %w(bareos-director bareos-database-postgresql).each do |pkg|
    describe package(pkg) do
      it { should be_installed }
      its('version') { should eq '16.2.4-12.1' }
    end
  end
end

control 'Bareos director service' do
  impact 0.7
  title 'Verify bareos director service'
  desc 'Ensures bareos director service is up and running'
  describe service('bareos-dir') do
    it { should be_enabled }
    it { should be_installed }
    it { should be_running }
  end
end
