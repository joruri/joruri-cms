# encoding: utf-8
class Sys::Script::TasksController < ApplicationController
  
  def exec
    task = Sys::Task.new
    task.and :process_at, '<=', Time.now + (60*5) # before 5 min
    task.and :process_at, '>', (Date.today << 1)
    tasks = task.find(:all, :order => :process_at)
    
    Script.total tasks.size
    
    if tasks.size == 0
      return render(:text => "OK")
    end
    
    tasks.each_with_index do |task, idx|
      begin
        unless unid = task.unid_data
          task.destroy
          raise "unid not found##{task.unid}"
        end
        
        model = unid.model.underscore.pluralize
        item  = eval(unid.model).find_by_unid(unid.id)
        
        model = "cms/nodes" if model == "cms/model/node/pages" # for v1.1.7
        
        task_ctr = model.gsub(/^(.*?)\//, '\1/script/')
        task_act = "#{task.name}_by_task"
        task_prm = params.merge(:unid => unid, :task => task, :item => item)
        render_component_into_view :controller => task_ctr, :action => task_act, :params => task_prm
      rescue => e
        Script.error e
      end
    end
    
    render(:text => "OK")
  end
end
