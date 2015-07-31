require 'puppet'
require 'set'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'rabbitmqctl'))
Puppet::Type.type(:rabbitmq_user).provide(:rabbitmqctl, :parent => Puppet::Provider::Rabbitmqctl) do

  if Puppet::PUPPETVERSION.to_f < 3
    commands :rabbitmqctl => 'rabbitmqctl'
  else
     has_command(:rabbitmqctl, 'rabbitmqctl') do
       environment :HOME => "/tmp"
     end
  end

  defaultfor :feature => :posix

  def retry_rabbitmqctl(*args)
    self.class.run_with_retries do
      rabbitmqctl(*args)
    end
  end

  def self.retry_rabbitmqctl(*args)
    self.run_with_retries do
      rabbitmqctl(*args)
    end
  end

  def self.instances
    retry_rabbitmqctl('-q', 'list_users').split(/\n/).collect do |line|
      if line =~ /^(\S+)(\s+\[.*?\]|)$/
        new(:name => $1)
      else
        raise Puppet::Error, "Cannot parse invalid user line: #{line}"
      end
    end
  end

  def create
    retry_rabbitmqctl('add_user', resource[:name], resource[:password])
    if resource[:admin] == :true
      make_user_admin()
    end
    if !resource[:tags].nil?
      set_user_tags(resource[:tags])
    end
  end

  def change_password
    retry_rabbitmqctl('change_password', resource[:name], resource[:password])
  end

  def password
    nil
  end


  def check_password
    response = retry_rabbitmqctl('eval', 'rabbit_access_control:check_user_pass_login(list_to_binary("' + resource[:name] + '"), list_to_binary("' + resource[:password] + '")).')
    if response.include? 'refused'
        false
    else
        true
    end
  end

  def destroy
    retry_rabbitmqctl('delete_user', resource[:name])
  end

  def exists?
    retry_rabbitmqctl('-q', 'list_users').split(/\n/).detect do |line|
      line.match(/^#{Regexp.escape(resource[:name])}(\s+(\[.*?\]|\S+)|)$/)
    end
  end


  def tags
    get_user_tags.entries.sort
  end


  def tags=(tags)
    if ! tags.nil?
      set_user_tags(tags)
    end
  end

  def admin
    if usertags = get_user_tags
      (:true if usertags.include?('administrator')) || :false
    else
      raise Puppet::Error, "Could not match line '#{resource[:name]} (true|false)' from list_users (perhaps you are running on an older version of rabbitmq that does not support admin users?)"
    end
  end

  def admin=(state)
    if state == :true
      make_user_admin()
    else
      usertags = get_user_tags
      usertags.delete('administrator')
      retry_rabbitmqctl('set_user_tags', resource[:name], usertags.entries.sort)
    end
  end

  def set_user_tags(tags)
    is_admin = get_user_tags().member?("administrator") \
               || resource[:admin] == :true
    usertags = Set.new(tags)
    if is_admin
      usertags.add("administrator")
    end
    retry_rabbitmqctl('set_user_tags', resource[:name], usertags.entries.sort)
  end

  def make_user_admin
    usertags = get_user_tags
    usertags.add('administrator')
    retry_rabbitmqctl('set_user_tags', resource[:name], usertags.entries.sort)
  end

  private
  def get_user_tags
    match = retry_rabbitmqctl('-q', 'list_users').split(/\n/).collect do |line|
      line.match(/^#{Regexp.escape(resource[:name])}\s+\[(.*?)\]/)
    end.compact.first
    Set.new(match[1].split(/, /)) if match
  end
end
