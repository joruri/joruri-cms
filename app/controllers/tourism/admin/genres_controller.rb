# encoding: utf-8
class Tourism::Admin::GenresController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  helper Cms::EmbeddedFileHelper
  
  def pre_dispatch
    return error_auth unless @content = Cms::Content.find(params[:content])
    #default_url_options[:content] = @content
    
    if params[:parent] == '0'
      @parent = Tourism::Genre.new({
        :level_no => 0
      })
      @parent.id = 0
    else
      @parent = Tourism::Genre.new.find(params[:parent])
    end
  end
  
  def index
    item = Tourism::Genre.new#.readable
    item.and :parent_id, @parent
    item.and :content_id, @content
    item.page  params[:page], params[:limit]
    item.order params[:sort], :sort_no
    @items = item.find(:all)
    _index @items
  end
  
  def show
    @item = Tourism::Genre.new.find(params[:id])
    _show @item
  end

  def new
    @item = Tourism::Genre.new({
      :state      => 'public',
      :sort_no    => 1,
    })
  end
  
  def create
    @item = Tourism::Genre.new(params[:item])
    @item.content_id = @content.id
    @item.parent_id = @parent.id
    @item.level_no  = @parent.level_no + 1
    
    @item.set_embedded_file_option :image_file_id,
      :resize    => @content.setting_value(:genre_resize_size)
    @item.set_embedded_file_option :list_image_file_id,
      :thumbnail => @content.setting_value(:genre_thumbnail_size)
    
    _create @item
  end
  
  def update
    @item = Tourism::Genre.new.find(params[:id])
    @item.attributes = params[:item]
    
    @item.set_embedded_file_option :image_file_id,
      :resize    => @content.setting_value(:genre_resize_size)
    @item.set_embedded_file_option :list_image_file_id,
      :thumbnail => @content.setting_value(:genre_thumbnail_size)
    
    _update @item
  end
  
  def destroy
    @item = Tourism::Genre.new.find(params[:id])
    _destroy @item
  end
  
  def spots(rendering = true)
    item = Tourism::Genre.new.public
    item.and :id, params[:genre_id]
    genre = item.find(:first)
    
    item = Tourism::Spot.new.public
    item.genre_is genre
    item.and :genre_ids, 0 unless genre
    spots = item.find(:all, :order => :title_kana)
    spots = spots.collect{|i| [i.title, i.id]}
    
    title = genre ? "#{genre.title}:" : nil
    @items  = [["// 一覧を更新しました（#{title}#{spots.size}件）",'']] + spots
    
    respond_to do |format|
      format.html { render :layout => false }
    end
  end
end
