# encoding: utf-8
class Cms::DataFile < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::File
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Site
  include Cms::Model::Rel::Concept
  include Cms::Model::Auth::Concept
  
  belongs_to :status , :foreign_key => :state     , :class_name => 'Sys::Base::Status'
  belongs_to :concept, :foreign_key => :concept_id, :class_name => 'Cms::Concept'
  belongs_to :site   , :foreign_key => :site_id   , :class_name => 'Cms::Site'
  belongs_to :node   , :foreign_key => :node_id   , :class_name => 'Cms::DataFileNode'
  
  attr_accessor :in_resize_size, :in_thumbnail_size
  
  validates_presence_of :concept_id
  
  before_save :set_published_at
  after_save :upload_public_file
  after_destroy :remove_public_file
  
  def states
    [['公開','public'],['非公開','closed']]
  end
  
  def public_path
    return nil unless site
    dir = Util::String::CheckDigit.check(format('%07d', id)).gsub(/(.*)(..)(..)(..)$/, '\1/\2/\3/\4/\1\2\3\4')
    "#{site.public_path}/_files/#{dir}/#{escaped_name}"
  end
  
  def public_uri
    dir = Util::String::CheckDigit.check(format('%07d', id))
    "/_files/#{dir}/#{escaped_name}"
  end
  
  def public_thumbnail_uri
    uri = public_uri
    ::File.dirname(uri) + "/thumb/" + ::File.basename(uri)
  end
  
  def public_full_uri
    "#{site.full_uri}#{public_uri.sub(/^\//, '')}"
  end
  
  def public_thumbnail_full_uri
    "#{site.full_uri}#{public_thumbnail_uri.sub(/^\//, '')}"
  end
  
  def public
    self.and :state, 'public'
    self
  end
  
  def publishable?
    return false unless editable?
    return !public? 
  end
  
  def closable?
    return false unless editable?
    return public?
  end
  
  def public?
    return published_at != nil
  end
  
  def has_thumbnail?
    !thumb_size.blank?
  end
  
  # def publish(options = {})
    # unless ::Storage.exists?(upload_path)
      # errors.add :base, 'ファイルデータが見つかりません。'
      # return false
    # end
    # self.state        = 'public'
    # self.published_at = Core.now
    # return false unless save(:validate => false)
    # remove_public_file
    # return upload_public_file
  # end
#   
  # def close
    # self.state        = 'closed'
    # self.published_at = nil
    # return false unless save(:validate => false)
    # return remove_public_file
  # end
  
  def duplicated?
    file = self.class.new
    file.and :id, "!=", id if id
    file.and :concept_id, concept_id
    file.and :name, name
    if node_id
      file.and :node_id, node_id
    else
      file.and :node_id, 'IS', nil
    end
    return file.find(:first) != nil
  end
  
  def search(params)
    params.each do |n, v|
      next if v.to_s == ''
      
      case n
      when 's_node_id'
        self.and :node_id, v
      when 's_name_or_title'
        self.and_keywords v, :name, :title
      end
    end if params.size != 0
    
    return self
  end

private
  def set_published_at
    self.published_at = (state == "public") ? Core.now : nil
  end
  
  def upload_public_file
    remove_public_file
    
    if state == "public"
      upl_path = upload_path
      pub_path = public_path
      
      if ::Storage.exists?(upl_path)
        ::Storage.mkdir_p(::File.dirname(pub_path))
        ::Storage.cp(upl_path, pub_path)
      end
      
      upl_path = ::File.dirname(upload_path) + "/thumb.dat"
      pub_path = ::File.dirname(public_path) + "/thumb/" + ::File.basename(public_uri)
      
      if ::Storage.exists?(upl_path)
        ::Storage.mkdir_p(::File.dirname(pub_path))
        ::Storage.cp(upl_path, pub_path)
      end
    end
    return true
  end
  
  def remove_public_file
    dir = ::File.dirname(public_path)
    ::Storage.rm_rf(dir) if ::Storage.exists?(dir)
    return true
  end
end
