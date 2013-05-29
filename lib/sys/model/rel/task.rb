# encoding: utf-8
module Sys::Model::Rel::Task
  
  def self.included(mod)
    mod.has_many :tasks, :primary_key => 'unid', :foreign_key => 'unid', :class_name => 'Sys::Task',
      :dependent => :destroy
      
    mod.after_save :save_tasks
  end
  
  def find_task_by_name(name)
    return nil if tasks.size == 0
    tasks.each do |task|
      return task.process_at if task.name == name.to_s
    end
    return nil
  end
  
  def in_tasks
    unless val = @in_tasks
      val = {}
      tasks.each {|task| val[task.name] = task.process_at.strftime('%Y-%m-%d %H:%M') if task.process_at }
      @in_tasks = val
    end
    @in_tasks
  end
  
  def in_tasks=(values)
    _values = {}
    if values.class == Hash || values.class == HashWithIndifferentAccess
      values.each {|key, val| _values[key] = val }
    end
    @tasks = _values
  end
  
  def save_tasks
    return false unless unid
    return true unless @tasks
    
    values = @tasks
    @tasks = nil
    
    values.each do |k, date|
      name = k.to_s
      
      if date == ''
        tasks.each do |task|
          task.destroy if task.name == name
        end
      else
        items = []
        tasks.each do |task|
          if task.name == name
            items << task
          end
        end
        
        if items.size > 1
          items.each {|task| task.destroy}
          items = []
        end
        
        if items.size == 0
          task = Sys::Task.new({:unid => unid, :name => name, :process_at => date})
          task.save
        else
          items[0].process_at = date
          items[0].save
        end
      end
    end
    
    tasks(true)
    return true
  end
end