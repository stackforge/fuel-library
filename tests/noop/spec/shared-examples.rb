# Shared functions
def filter_nodes(hash, name, value)
  hash.select do |it|
    it[name] == value
  end
end

def nodes_to_hash(hash, name, value)
  result = {}
  hash.each do |element|
    result[element[name]] = element[value]
  end
  result
end

def ipsort (ips)
  require 'rubygems'
  require 'ipaddr'
  ips.sort { |a,b| IPAddr.new( a ) <=> IPAddr.new( b ) }
end

def test_ubuntu_and_centos(manifest, force_manifest = false)
  # check if task is present in the task list
  unless force_manifest or Noop.manifest_present? manifest
    # puts "Manifest '#{manifest}' is not enabled on the node '#{Noop.hostname}'. Skipping tests."
    return
  end

  # set manifest file
  before(:all) do
    Noop.manifest = manifest
  end

  let(:os) do
    os = facts[:operatingsystem]
    os = os.downcase if os
    os
  end

  let(:catalog) do
    catalog = subject
    catalog = subject.call if subject.is_a? Proc
    catalog
  end

  let(:file_resources) do
   files = catalog.resources.select do |resource|
      resource.type == 'File'
   end
   files
  end

  shared_examples 'compile' do
    it do
      File.stubs(:exists?).with('/var/lib/astute/ceph/ceph').returns(true)
      File.stubs(:exists?).with('/var/lib/astute/mongodb/mongodb.key').returns(true)
      File.stubs(:exists?).with('/var/lib/astute/mongodb/mongodb.key').returns(true)
      File.stubs(:exists?).with('/var/lib/astute/ceph/ceph').returns(true)
      File.stubs(:exists?).with('/var/lib/astute/nova/nova').returns(true)
      File.stubs(:exists?).with('/var/lib/astute/ceph/ceph').returns(true)
      File.stubs(:exists?).returns(false)
      should compile.with_all_deps
    end
  end


  shared_examples 'should_not_install_bin_files_with_puppet' do
    it 'should not install binary files with puppet' do
      p file_resources
      binary_files=Regexp.new('^/bin|^/usr/bin|^/usr/local/bin|^/usr/sbin|^/sbin|^/usr/lib|^/usr/share')
      bin_files=0
      bin_files_array=[]
      down_files=0
      down_files_array=[]
      file_resources.each do |resource|
        next unless %w(present file directory).include? resource[:ensure] or not resource[:ensure]
        if binary_files.match resource[:path]
          bin_files+=1
          bin_files_array << resource[:path].to_s
        elsif binary_files.match resource[:title]
          bin_files+=1
          bin_files_array << resource[:title].to_s
        elsif resource[:source]
          down_files+=1
          if !resource[:path].to_s.empty? ? resource[:path] : resource[:title]
            down_files_array << resource[:path].to_s
          else
            down_files_array << resource[:title].to_s
          end
        end
     end
error_message_template = <<-eos
<% if bin_files != 0 -%>
You have <%= bin_files -%> binary files installed with puppet:
<% bin_files_array.each do |file| -%>
<%= file %>
<% end -%>
<% end -%>
<% if down_files != 0 -%>
You are downloading <%= down_files -%> binary files installed with puppet:
<% down_files_array.each do |file| -%>
<%= file %>
<% end -%>
<% end -%>
eos
     fail ERB.new(error_message_template,nil,'-').result(binding) if bin_files!=0 or down_files!=0
 
    end
  end

  shared_examples 'save_files_list' do
    it 'should save the list of file resources' do
      files={}
      file_resources.each do |resource|
        next unless %w(present file directory).include? resource[:ensure] or not resource[:ensure]
        if resource[:source]
          content = resource[:source]
        elsif resource[:content]
          content = 'TEMPLATE'
        else
          content = nil
        end
        next unless content
        files[resource[:path]] = content
        if files.any?
          Noop.save_file_resources_list files, manifest, os
        end
      end
    end
  end

  shared_examples 'save_packages_list' do
    it 'should save the list of file resources' do
      catalog = subject
      catalog = subject.call if subject.is_a? Proc
      package_resources = {}
      catalog.resources.each do |resource|
        next unless resource.type == 'Package'
        next if %w(absent purged).include? resource[:ensure] or not resource[:ensure]
        package_resources[resource[:name]] = resource[:ensure]
      end
      if package_resources.any?
        Noop.save_package_resources_list package_resources, manifest, os
      end
    end
  end

  shared_examples 'debug' do
    it 'shows catalog contents' do
      Noop.show_catalog subject
    end
  end

  shared_examples 'generate' do
    it 'shows catalog contents' do
      Noop.catalog_to_spec subject
    end
  end

  shared_examples 'status' do
    it 'shows status' do
      puts <<-eos
      =============================================
      OS:       #{os}
      YAML:     #{Noop.astute_yaml_base}
      Manifest: #{Noop.manifest}
      Node:     #{Noop.fqdn}
      Role:     #{Noop.hiera 'role'}
      =============================================
      eos
    end
  end

  #######################################
  # Testing on different operating systems

  if Noop.test_ubuntu?
    context 'on Ubuntu platforms' do
      let(:facts) { Noop.ubuntu_facts }

      it_behaves_like 'compile'

      it_behaves_like 'status' if ENV['SPEC_SHOW_STATUS']
      it_behaves_like 'debug' if ENV['SPEC_CATALOG_DEBUG']
      it_behaves_like 'generate' if ENV['SPEC_SPEC_GENERATE']
      it_behaves_like 'save_files_list' if ENV['SPEC_SAVE_FILE_RESOURCES']
      it_behaves_like 'save_packages_list'if ENV['SPEC_SAVE_PACKAGE_RESOURCES']
      it_behaves_like 'should_not_install_bin_files_with_puppet' if ENV['SPEC_CHECK_FILES'] !~ /false/i

      begin
        it_behaves_like 'catalog'
      rescue ArgumentError
        true
      end

      at_exit { RSpec::Puppet::Coverage.report! } if ENV['SPEC_COVERAGE']
    end
  end

  if Noop.test_centos?
    context 'on CentOS platforms' do
      let(:facts) { Noop.centos_facts }

      it_behaves_like 'compile'

      it_behaves_like 'status' if ENV['SPEC_SHOW_STATUS']
      it_behaves_like 'debug' if ENV['SPEC_CATALOG_DEBUG']
      it_behaves_like 'generate' if ENV['SPEC_SPEC_GENERATE']
      it_behaves_like 'save_files_list' if ENV['SPEC_SAVE_FILE_RESOURCES']
      it_behaves_like 'save_packages_list'if ENV['SPEC_SAVE_PACKAGE_RESOURCES']
      it_behaves_like 'should_not_install_bin_files_with_puppet' if ENV['SPEC_CHECK_FILES'] !~ /false/i

      begin
        it_behaves_like 'catalog'
      rescue ArgumentError
        true
      end

      at_exit { RSpec::Puppet::Coverage.report! } if ENV['SPEC_COVERAGE']
    end
  end

end

