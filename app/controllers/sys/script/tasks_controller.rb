# encoding: utf-8
class Sys::Script::TasksController < ApplicationController
  def exec
    arel_table = Sys::Task.arel_table
    tasks = Sys::Task
            .where(arel_table[:process_at].lteq(Time.now))
            .where(arel_table[:process_at].gt((Date.today << 1)))
            .order(:process_at)

    items = []
    tasks.each do |task|
      unless unid = task.unid_data
        task.destroy
        next
      end
      items << task
    end
    
    Script.total items.size

    return render(text: 'OK') if items.empty?

    items.each_with_index do |task, _idx|
      begin
        unless unid = task.unid_data
          task.destroy
          raise "unid not found##{task.unid}"
        end

        model = unid.model.underscore.pluralize
        item  = eval(unid.model).find_by(unid: unid.id)

        model = 'cms/nodes' if model == 'cms/model/node/pages' # for v1.1.7

        task_ctr = model.gsub(/^(.*?)\//, '\1/script/')
        task_act = "#{task.name}_by_task"
        task_prm = params.merge(unid: unid, task: task, item: item)
        render_component_into_view controller: task_ctr, action: task_act, params: task_prm
      rescue => e
        Script.error e
      end
    end

    render(text: 'OK')
  end
end
