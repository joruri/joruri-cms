# encoding: utf-8
class Tourism::Spot < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Cms::Model::Base::Page::Publisher
  include Cms::Model::Base::Page::TalkTask
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::UnidRelation
  include Sys::Model::Rel::Creator
  include Sys::Model::Rel::Task
  include Cms::Model::Rel::Map
  include Cms::Model::Rel::EmbeddedFile
  include Tourism::Model::Rel::Spot::Genre
  include Tourism::Model::Rel::Spot::Area
  include Cms::Model::Auth::Concept
  include Sys::Model::Auth::EditableGroup

  belongs_to :content,        :foreign_key => :content_id,        :class_name => 'Tourism::Content::Spot'
  belongs_to :status,         :foreign_key => :state,             :class_name => 'Sys::Base::Status'
  
  has_many :photos, :foreign_key => :spot_id, :class_name => 'Tourism::Photo', :dependent => :destroy
  has_many :movies, :foreign_key => :spot_id, :class_name => 'Tourism::Movie', :dependent => :destroy
  has_many :mouths, :foreign_key => :spot_id, :class_name => 'Tourism::Mouth', :dependent => :destroy
  
  attr_accessor :bread_crumbs_type
  attr_accessor :s_genre_id, :s_area_id
  
  embed_file_of :image_file_id
  embed_file_of :detail_image1_file_id, :detail_image2_file_id, :detail_image3_file_id
  embed_file_of :detail_info1_file_id, :detail_info2_file_id, :detail_info3_file_id
  
  validates_presence_of :title
  
  validates_uniqueness_of :name, :scope => :content_id
  
  before_save :check_digit
  before_save :before_publish,
    :if => %Q(state == "public")
  
  def public_path
    if name =~ /^[0-9]{13}$/
      _name = name.gsub(/^((\d{4})(\d\d)(\d\d)(\d\d)(\d\d).*)$/, '\2/\3/\4/\5/\6/\1')
    else
      _name = ::File.join(name[0..0], name[0..1], name[0..2], name)
    end
    "#{content.public_path}/spots/#{_name}/index.html"
  end

  def public_uri=(uri)
    @public_uri = uri
  end
  
  def public_uri
    return @public_uri if @public_uri
    return nil unless node = content.spot_node
    @public_uri = "#{node.public_uri}#{name}/"
  end
  
  def public_full_uri
    return nil unless node = content.spot_node
    "#{node.public_full_uri}#{name}/"
  end
  
  def has_detail_contents?
    return !detail_body.blank?
  end
  
  def bread_crumbs(spot_node)
    return contents_bread_crumbs(spot_node, bread_crumbs_type) if bread_crumbs_type
    
    crumbs = []
    
    if content = Tourism::Content::Spot.find_by_id(content_id)
      node  = content.genre_node
      items = genre_items(:state => "public")
      if node && items.size > 0
        c = node.bread_crumbs.crumbs[0]
        c << items.collect{|i| [i.title, "#{node.public_uri}#{i.name}/"]}
        crumbs << c
      end
      
      node  = content.area_node
      items = area_items(:state => "public")
      if node && items.size > 0
        c = node.bread_crumbs.crumbs[0]
        c << items.collect{|i| [i.title, "#{node.public_uri}#{i.name}/"]}
        crumbs << c
      end
    end
    
    if crumbs.size == 0
      spot_node.routes.each do |r|
        c = []
        r.each {|i| c << [i.title, i.public_uri] }
        crumbs << c
      end
    end
    Cms::Lib::BreadCrumbs.new(crumbs)
  end
  
  def contents_bread_crumbs(node, type)
    crumbs = []
    node ||= self
    node.routes.each do |r|
      c = r.collect{|i| [i.title, i.public_uri]}
      c << [title, public_uri]
      crumbs << c
    end
    if type == :photo && content.photo_node
      content.photo_node.routes.each do |r|
        c = r.collect {|i| [i.title, i.public_uri] }
        crumbs << c
      end
    end
    if type == :movie && content.movie_node
      content.movie_node.routes.each do |r|
        c = r.collect {|i| [i.title, i.public_uri] }
        crumbs << c
      end
    end
    if type == :mouth && content.mouth_node
      content.mouth_node.routes.each do |r|
        c = r.collect {|i| [i.title, i.public_uri] }
        crumbs << c
      end
    end
    Cms::Lib::BreadCrumbs.new(crumbs)
  end
  
  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_id'
        self.and "#{Tourism::Spot.table_name}.id", v
      when 's_genre_id'
        return self.and(0, 1) unless cate = Tourism::Genre.find_by_id(v)
        #return self.genre_in(cate.public_children) if cate.level_no == 1
        self.genre_is(cate)
      # when 's_genres'
        # ids = ['x']
        # if v.is_a?(Hash)
          # ids = ''
          # v.keys.each do |id|
            # item = Tourism::Genre.find_by_id(id) || 'x'
            # ids += self.class.new.genre_is(item).condition.where[1] if item
          # end
          # ids = ids.split(/[^0-9]+/).uniq
          # ids.delete('')
        # end
        # self.and :genre_ids, 'REGEXP', "(^| )(#{ids.join('|')})( |$)"
      when 's_area_id'
        return self.and(0, 1) unless area = Tourism::Area.find_by_id(v)
        #return self.area_is(area.public_children) if area.level_no == 1
        self.area_is(area)
      # when 's_areas'
        # ids = ['x']
        # if v.is_a?(Hash)
          # ids = ''
          # v.keys.each do |id|
            # item = Tourism::Area.find_by_id(id) || 'x'
            # ids += self.class.new.area_is(item).condition.where[1] if item
          # end
          # ids = ids.split(/[^0-9]+/).uniq
          # ids.delete('')
        # end
        # self.and :area_ids, 'REGEXP', "(^| )(#{ids.join('|')})( |$)"
      when 's_title'
        self.and_keywords v, :title
      when 's_keyword'
        self.and_keywords v, :title, :body
      when 's_affiliation_name'
        self.join :creator
        self.join "INNER JOIN #{Sys::Group.table_name} ON #{Sys::Group.table_name}.id = #{Sys::Creator.table_name}.group_id"
        self.and "#{Sys::Group.table_name}.name", "LIKE", "%#{v}%"
      end
    end if params.size != 0

    return self
  end

  def default_map_position
    v = content.setting_value(:default_map_position)
    v.blank? ? super : v
  end
  
  def inquiry_email_setting
    v = content.setting_value(:inquiry_email_display)
    v.blank? ? super : v
  end
  
  def check_digit
    return true if name.to_s != ''
    date = Date.strptime(Core.now, '%Y-%m-%d').strftime('%Y%m%d')
    date = created_at.strftime('%Y%m%d') if created_at
    seq  = Util::Sequencer.next_id('tourism_spots', :version => date)
    name = date + format('%04d', seq)
    self.name = Util::String::CheckDigit.check(name)
    return true
  end
  
  def before_publish
    self.published_at ||= Core.now
    return true
  end
  
  # group chenge
  def information
    return "[記事]\n#{id} #{title}"
  end
end