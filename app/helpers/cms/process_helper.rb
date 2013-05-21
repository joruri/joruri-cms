# encoding: utf-8
module Cms::ProcessHelper
  
  def script_state_view(name, options = {})
    options[:proc] = Sys::Process.find_by_name(name) || Sys::Process.new(:name => name)
    render :partial => 'cms/admin/_partial/processes/view', :locals => options
  end
  
end