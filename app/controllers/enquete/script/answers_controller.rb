# encoding: utf-8
class Enquete::Script::AnswersController < ApplicationController

  def pull
    Util::Config.load(:database, :section => false).each do |section, spec|
      next if section.to_s !~ /^#{Rails.env.to_s}_pull_database/ ## only pull_database
      
      begin
        @db = SlaveBase.establish_connection(spec).connection
        
        sql = "SELECT id FROM enquete_answers WHERE created_at < '#{(Time.now - 5).strftime('%Y-%m-%d %H:%M:%S')}'"
        ans = @db.execute(sql)
        
        Script.total ans.size
        
        ans.each(:as => :hash) do |v|
          Script.current
          pull_answer v["id"]
          Script.success
        end
        
      rescue Script::InterruptException => e
        raise e
      rescue => e
        Script.error e.to_s
      end
    end
    return render(:text => "OK")
  end

protected
  def pull_answer(id)
    sql = "SELECT * FROM enquete_answers WHERE id = #{id}"
    
    @db.execute(sql).each(:as => :hash) do |ans_row|
      ans = Enquete::Answer.new(ans_row)
      ans.save
      
      sql = "SELECT * FROM enquete_answer_columns WHERE answer_id = #{id}"
      @db.execute(sql).each(:as => :hash) do |col_row|
        col = Enquete::AnswerColumn.new(col_row)
        col.answer_id = ans.id
        col.save
      end
    end
    
    @db.execute("DELETE FROM enquete_answer_columns WHERE answer_id = #{id}")
    @db.execute("DELETE FROM enquete_answers WHERE id = #{id}")
  end
end
