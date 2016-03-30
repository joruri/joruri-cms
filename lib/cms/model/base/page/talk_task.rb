# encoding: utf-8
require 'digest/md5'
module Cms::Model::Base::Page::TalkTask
  extend ActiveSupport::Concern

  included do
    has_many :talk_tasks, foreign_key: 'unid', primary_key: 'unid',
                          class_name: 'Cms::TalkTask', dependent: :destroy
    after_save :delete_talk_tasks
  end

  def publish_page(content, options = {})
    pub = super
    return false unless pub
    return pub if pub.path !~ /\.html$/

    cond = if options[:dependent]
             ['dependent = ?', options[:dependent].to_s]
           else
             ['dependent IS NULL']
           end
    task = talk_tasks.find_by(cond) || Cms::TalkTask.new

    mp3 = "#{pub.full_path}.mp3"

    if !published? && task.published_at && ::Storage.exists?(mp3)
      return pub if task.published_at > Cms::KanaDictionary.dic_mtime
    end

    if task.published_at && ::Storage.exists?(mp3)
      task.published_at = nil if task.content_hash != pub.content_hash
    end

    task.unid         = pub.unid
    task.dependent    = pub.dependent
    task.path         = pub.path
    task.content_hash = pub.content_hash
    task.save if task.changed?

    pub
  end

  def delete_talk_tasks
    talk_tasks.destroy_all
    true
  end
end
