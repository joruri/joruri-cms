# encoding: utf-8
class Cms::Layout < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page::Publisher
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Site
  include Cms::Model::Rel::Concept
  include Cms::Model::Auth::Concept

  belongs_to :status, foreign_key: :state, class_name: 'Sys::Base::Status'

  validates :concept_id, :state, :title, presence: true
  validates :name, presence: true, uniqueness: { scope: [:concept_id] },
                   format: { with: /\A[0-9a-zA-Z\-_]+\Z/, if: 'name.present?',
                             message: "は半角英数字、ハイフン、アンダースコアで入力してください。" }

  after_destroy :remove_css_files

  scope :search, -> (params) {
    rel = all

    layouts = arel_table

    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_name_or_title'
        rel = rel.where(layouts[:title].matches("%#{v}%")
          .or(layouts[:name].matches("%#{v}%")))
      when 's_keyword'
        matches_proc = proc do |matches, nn|
          if matches
            matches.or(layouts[nn].matches("%#{v}%"))
          else
            layouts[nn].matches("%#{v}%")
          end
        end

        matches = nil

        [:name, :title, :head, :body, :stylesheet, :mobile_head, :mobile_body,
         :mobile_stylesheet, :smart_phone_head, :smart_phone_body, :smart_phone_stylesheet].each do |nn|
          matches = matches_proc.call(matches, nn)
        end

        rel = rel.where(matches) if matches
      end
    end if params.size != 0

    rel
  }

  def self.find_contains_piece_name(name)
    where(
      self.arel_table[:body].matches("%[[piece/#{name}]]%")
      .or(self.arel_table[:mobile_body].matches("%[[piece/#{name}]]%"))
      .or(self.arel_table[:smart_phone_body].matches("%[[piece/#{name}]]%"))
    )
    .order(:concept_id, :name)
  end

  def states
    [%w(公開 public)]
  end

  def publishable? # TODO: dummy
    true
  end

  def piece_names
    names = []
    body.scan(/\[\[piece\/([0-9a-zA-Z_-]+)\]\]/) do |name|
      names << name[0]
    end
    names.uniq
  end

  def pieces(concept = nil)
    pieces = []
    piece_names.each do |name|
      if concept
        piece = Cms::Piece.where(name: name, concept_id: concept)
                          .order(:id)
                          .first
      end
      unless piece
        piece = Cms::Piece.where(name: name, concept_id: self.concept)
                          .order(:id)
                          .first
      end
      unless piece
        piece = Cms::Piece.where(name: name, concept_id: nil)
                          .order(:id)
                          .first
      end
      pieces << piece if piece
    end
    pieces
  end

  def head_tag(request)
    tags = []

    if uri = stylesheet_uri(request)
      tags << %(<link href="#{uri}" media="all" rel="stylesheet" type="text/css" />)
    end

    tags << if request.mobile? && !mobile_head.blank?
              mobile_head
            elsif request.smart_phone? && !smart_phone_head.blank?
              smart_phone_head
            else
              head.to_s
            end

    tags.delete('')
    tag = tags.join("\n")
    tag = tag.gsub(/<link [^>]+>/i, '').gsub(/(\r\n|\n)+/, "\n") if request.mobile?
    tag.html_safe
  end

  def body_tag(request)
    if request.mobile? && !mobile_body.blank?
      mobile_body
    elsif request.smart_phone? && !smart_phone_body.blank?
      smart_phone_body
    else
      body
    end
  end

  def stylesheet_uri(request)
    return nil unless id
    dir = site.uri + '_layouts/' + Util::String::CheckDigit.check(format('%07d', id))

    if request.mobile? && !mobile_stylesheet.blank?
      dir + '/mobile.css'
    elsif request.smart_phone? && !smart_phone_stylesheet.blank?
      dir + '/smart_phone.css'
    else
      dir + '/style.css'
    end
  end

  def stylesheet_path
    return nil unless id
    dir = Util::String::CheckDigit.check(format('%07d', id))
    dir = dir.gsub(/(\d\d)(\d\d)(\d\d)(\d\d)/, '\1/\2/\3/\4/\1\2\3\4')
    dir = site.public_path + '/_layouts/' + dir

    dir + '/style.css'
  end

  def public_path
    site.public_path + '/layout/' + name + '/style.css'
  end

  def public_uri # TODO: dummy
    '/layout/' + name + '/style.css'
  end

  def request_publish_data # TODO: dummy
    _res = {
      page_type: 'text/css',
      page_size: stylesheet.size,
      page_data: stylesheet
    }
  end

  def tamtam_css
    css = ''
    mobile_head.scan(/<link [^>]*?rel="stylesheet"[^>]*?>/i) do |m|
      css += %(@import "#{m.gsub(/.*href="(.*?)".*/, '\1')}";\n)
    end
    css += mobile_stylesheet unless mobile_stylesheet.blank?

    4.times do
      css = convert_css_for_tamtam(css)
    end
    css.gsub!(/^@.*/, '')
    css.gsub!(/[a-z]:after/i, '-after')
    css
  end

  def convert_css_for_tamtam(css)
    css.gsub(/^@import .*/) do |m|
      path = m.gsub(/^@import ['"](.*?)['"];/, '\1')
      dir  = (path =~ /^\/_common\//) ? "#{Rails.root}/public" : site.public_path
      file = "#{dir}#{path}"
      if ::Storage.exists?(file)
        m = ::Storage.read(file).to_utf8.gsub(/(\r\n|\n|\r)/, "\n").gsub(/^@import ['"](.*?)['"];/) do |m2|
          p = m2.gsub(/.*?["'](.*?)["'].*/, '\1')
          p = ::File.expand_path(p, ::File.dirname(path)) if p =~ /^\./
          %(@import "#{p}";)
        end
      else
        m = ''
      end
      m
    end
  end

  def extended_css(options = {})
    css = extend_css(public_path)
    if options[:skip_charset] == true
      css.gsub!(/(^|\n)@charset .*?(\n|$)/, '\1')
    end
  end

  def extend_css(path)
    return '' unless ::Storage.exists?(path)
    css = ::Storage.read(path)
    if css =~ /^@import/
      css.gsub!(/(^|\n)@import .*?(\n|$)/iom) do |m|
        src = m.gsub(/(^|\n)@import ["](.*)["].*?(\n|$)/, '\2')
        if src.slice(0, 9) == '/_common/'
          src = "#{Rails.root}/public#{src}"
        elsif src.slice(0, 1) != '/'
          src = ::File.dirname(path) + '/' + src
        else
          '/* skip */'
        end
        extend_css(src) + "\n"
      end
    end
    css
  end

  def put_css_files
    path = stylesheet_path
    ::Storage.mkdir_p(::File.dirname(path))
    ::Storage.write(path, stylesheet.to_s)

    path = ::File.dirname(path) + '/mobile.css'
    ::Storage.mkdir_p(::File.dirname(path))
    ::Storage.write(path, mobile_stylesheet.to_s)

    path = ::File.dirname(path) + '/smart_phone.css'
    ::Storage.mkdir_p(::File.dirname(path))
    ::Storage.write(path, smart_phone_stylesheet.to_s)

    true
  end

  def remove_css_files
    path = stylesheet_path
    ::Storage.rm_rf(path)

    path = ::File.dirname(path) + '/mobile.css'
    ::Storage.rm_rf(path)

    path = ::File.dirname(path) + '/smart_phone.css'
    ::Storage.rm_rf(path)

    begin
      ::Storage.rmdir(::File.dirname(path))
    rescue
      nil
    end
    true
  end

  def duplicate(rel_type = nil)
    item = self.class.new(attributes)
    item.id            = nil
    item.unid          = nil
    item.created_at    = nil
    item.updated_at    = nil
    item.recognized_at = nil
    item.published_at  = nil

    if rel_type.nil?
      item.name          = nil
      item.title         = item.title.gsub(/^(【複製】)*/, "【複製】")
    end

    item.save(validate: false)
  end
end
