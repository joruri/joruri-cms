# encoding: utf-8
require 'digest/md5'
class Cms::Script::TalksController < Cms::Controller::Script::Publication
  def publish
    unless Joruri.config[:cms_use_kana]
      Script.log 'use_kana is disabled (application.yml)'
      return render(text: 'OK')
    end

    @kana_mtime = Cms::KanaDictionary.dic_mtime

    tasks = Cms::TalkTask.all.order(:id).select(:id)

    Script.total tasks.size

    tasks.each_with_index do |v, _idx|
      task = Cms::TalkTask.find_by(id: v[:id])
      next unless task

      begin
        Script.current
        Script.success if make_sound(task)
        task.published_at = Time.now
        task.save
      rescue Script::InterruptException => e
        raise e
      rescue Exception => e
        task.destroy
        Script.error e
      end
    end

    render text: 'OK'
  end

  def make_sound(task)
    src = task.full_path
    dst = task.mp3_path

    raise "No such file - #{src}" unless ::Storage.exists?(src)

    content = ::Storage.read(src).to_s
    raise "Content is empty - #{src}" if content.blank?

    if ::Storage.exists?(dst) && task.content_hash == Digest::MD5.new.update(content).to_s
      return false if task.published_at && task.published_at > @kana_mtime
    end

    talk = Cms::Lib::Navi::Jtalk.new
    talk.make(content)
    mp3 = talk.output
    raise "Sound is empty - #{src}" unless mp3

    mp3 = mp3[:path]
    raise "Sound is empty - #{src}" if ::File.stat(mp3).size == 0

    ::Storage.binwrite(dst, ::File.read(mp3))
    ::Storage.chmod(0644, dst)

    true
  end
end
