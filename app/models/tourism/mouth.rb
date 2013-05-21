# encoding: utf-8
class Tourism::Mouth < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Cms::Model::Base::Page::Publisher
  include Cms::Model::Base::Page::TalkTask
  include Sys::Model::Tree
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Concept
  include Cms::Model::Rel::EmbeddedFile
  include Cms::Model::Auth::Concept
  #include Sys::Model::Auth::EditableGroup
  
  belongs_to :status ,  :foreign_key => :state,      :class_name => 'Sys::Base::Status'
  belongs_to :content,  :foreign_key => :content_id, :class_name => 'Tourism::Content::Spot'
  belongs_to :genre,  :foreign_key => :genre_id, :class_name => 'Tourism::Genre'
  belongs_to :spot,  :foreign_key => :spot_id, :class_name => 'Tourism::Spot'
  
  attr_accessor :genre_id, :genre # for editing form
  attr_accessor :s_keyword, :s_spot
  
  embed_file_of :image1_file_id, :image2_file_id, :image3_file_id
  
  validates_presence_of :state, :spot_id, :title, :body, :guest_name
  
  apply_simple_captcha :message => "画像と文字が一致しません。", :add_to_base => true
  
  validates_length_of :title, :maximum => 50
  validates_length_of :body, :maximum => 500
  
  before_save :check_digit
  
  def public_path
    if name =~ /^[0-9]{13}$/
      _name = name.gsub(/^((\d{4})(\d\d)(\d\d)(\d\d)(\d\d).*)$/, '\2/\3/\4/\5/\6/\1')
    else
      _name = ::File.join(name[0..0], name[0..1], name[0..2], name)
    end
    "#{content.public_path}/mouths/#{_name}/index.html"
  end

  def public_uri=(uri)
    @public_uri = uri
  end
  
  def public_uri
    return @public_uri if @public_uri
    return nil unless node = content.mouth_node
    @public_uri = "#{node.public_uri}#{name}/"
  end
  
  def public_full_uri
    return nil unless node = content.mouth_node
    "#{node.public_full_uri}#{name}/"
  end
  
  def image_num
    count  = 0
    count +=1 if image1_file_id
    count +=1 if image2_file_id
    count +=1 if image3_file_id
    count
  end
  
  def check_digit
    return true if name.to_s != ''
    date = Date.strptime(Core.now, '%Y-%m-%d').strftime('%Y%m%d')
    date = created_at.strftime('%Y%m%d') if created_at
    seq  = Util::Sequencer.next_id('tourism_mouths', :version => date)
    name = date + format('%04d', seq)
    self.name = Util::String::CheckDigit.check(name)
    return true
  end
  
  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_id'
        self.and "#{self.class.table_name}.id", v
      when 's_title'
        self.and_keywords v, :title
      when 's_keyword'
        self.and_keywords v, :title, :body, :guest_name, :email
      when 's_spot'
        item = Tourism::Spot.new
        item.search("s_title" => v)
        ids = item.find(:all, :select => :id).collect{|c| c.id }
        self.and :spot_id, 'IN', ids
      end
    end if params.size != 0

    return self
  end
  
  def bread_crumbs(node)
    crumbs = []
    if content.spot_node && spot
      content.spot_node.routes.each do |r|
        c = r.collect {|i| [i.title, i.public_uri] }
        c << [spot.title, spot.public_uri]
        crumbs << c
      end
    end
    node.routes.each do |r|
      c = r.collect {|i| [i.title, i.public_uri] }
      crumbs << c
    end
    Cms::Lib::BreadCrumbs.new(crumbs)
  end
end
