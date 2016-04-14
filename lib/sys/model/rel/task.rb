# encoding: utf-8
module Sys::Model::Rel::Task
  extend ActiveSupport::Concern

  included do
    has_many :tasks, primary_key: 'unid', foreign_key: 'unid',
                     class_name: 'Sys::Task', dependent: :destroy

    after_save :save_tasks
  end

  def find_task_by_name(name)
    return nil if tasks.empty?

    tasks.each do |task|
      return task.process_at if task.name == name.to_s
    end

    nil
  end

  def in_tasks
    val = @in_tasks
    unless val
      val = {}
      tasks.each do |task|
        if task.process_at
          val[task.name] = task.process_at.strftime('%Y-%m-%d %H:%M')
        end
      end
      @in_tasks = val
    end

    @in_tasks
  end

  def in_tasks=(values)
    _values = {}
    if values.class == Hash || values.class == HashWithIndifferentAccess \
       || values.class == ActionController::Parameters
      values.each { |key, val| _values[key] = val }
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
          items << task if task.name == name
        end

        if items.size > 1
          items.each(&:destroy)
          items = []
        end

        if items.empty?
          task = Sys::Task.new(unid: unid, name: name, process_at: date)
          task.save
        else
          items[0].process_at = date
          items[0].save
        end
      end
    end

    tasks(true)
    true
  end
end
