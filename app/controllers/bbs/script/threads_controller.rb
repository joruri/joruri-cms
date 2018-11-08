# encoding: utf-8
class Bbs::Script::ThreadsController < Cms::Controller::Script::Publication
  def self.publishable?
    false
  end

  def publish
    render text: 'OK'
  end

  def pull
    Util::Config.load(:database, section: false).each do |section, spec|
      next if section.to_s !~ /^#{Rails.env.to_s}_pull_database/ ## only pull_database

      begin
        @db = SlaveBase.establish_connection(spec).connection
        ActiveRecord::Base.connection.execute('TRUNCATE TABLE bbs_items')
        pull_items
      rescue Script::InterruptException => e
        raise e
      rescue => e
        Script.error e.to_s
      end
    end
    render(text: 'OK')
  end

  def pull_items
    sql = "SELECT id FROM bbs_items"
    items = @db.execute(sql)

    Script.total items.size
    
    items.each(as: :hash) do |v|
      Script.current
      pull_item v['id']
      Script.success
    end
  end
  
  def pull_item(id)
    sql = "SELECT * FROM bbs_items WHERE id = #{id}"
    @db.execute(sql).each(as: :hash) do |v|
      item = Bbs::Item.new(v)
      Bbs::Item.record_timestamps = false
      item.save!
      Bbs::Item.record_timestamps = true
    end
  end

end
