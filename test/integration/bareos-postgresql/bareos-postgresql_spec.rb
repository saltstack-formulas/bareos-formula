# encoding: utf-8

case os[:name]
when 'centos'
  repo_file = '/etc/yum.repos.d/bareos.repo'
  repo_url = 'baseurl=http://download.bareos.org/bareos/release/latest/CentOS_7/'
when 'ubuntu'
  repo_file = '/etc/apt/sources.list.d/bareos.list'
  repo_url = 'deb http://download.bareos.org/bareos/release/latest/xUbuntu_16.04 ./'
when 'debian'
  repo_file = '/etc/apt/sources.list.d/bareos.list'
  repo_url = 'deb http://download.bareos.org/bareos/release/latest/Debian_9.0 ./'
end

control 'Bareos source list' do
  impact 0.6
  title 'Bareos source list'
  desc 'Ensures bareos source is installed'
  describe file(repo_file) do
    its('content') { should match repo_url }
  end
end

control 'Bareos packages' do
  impact 0.7
  title 'Verify bareos packages'
  desc 'Ensures bareos packages are installed with the right version'
  %w(bareos-director bareos-database-postgresql).each do |pkg|
    describe package(pkg) do
      it { should be_installed }
      its('version') { should match '18.2.5-139.1' }
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
