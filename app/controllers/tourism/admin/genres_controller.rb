# encoding: utf-8
class Tourism::Admin::GenresController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  helper Cms::EmbeddedFileHelper

  def pre_dispatch
    @content = Cms::Content.find(params[:content])
    return error_auth unless @content

    if params[:parent] == '0'
      @parent = Tourism::Genre.new(level_no: 0)
      @parent.id = 0
    else
      @parent = Tourism::Genre.find(params[:parent])
    end
  end

  def index
    @items = Tourism::Genre
             .where(parent_id: @parent)
             .where(content_id: @content)
             .order(params[:sort], :sort_no)
             .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Tourism::Genre.find(params[:id])
    _show @item
  end

  def new
    @item = Tourism::Genre.new(state: 'public',
                               sort_no: 1)
  end

  def create
    @item = Tourism::Genre.new(params[:item])
    @item.content_id = @content.id
    @item.parent_id = @parent.id
    @item.level_no  = @parent.level_no + 1

    @item.set_embedded_file_option :image_file_id,
                                   resize: @content.setting_value(:genre_resize_size)
    @item.set_embedded_file_option :list_image_file_id,
                                   thumbnail: @content.setting_value(:genre_thumbnail_size)

    _create @item
  end

  def update
    @item = Tourism::Genre.find(params[:id])
    @item.attributes = params[:item]

    @item.set_embedded_file_option :image_file_id,
                                   resize: @content.setting_value(:genre_resize_size)
    @item.set_embedded_file_option :list_image_file_id,
                                   thumbnail: @content.setting_value(:genre_thumbnail_size)

    _update @item
  end

  def destroy
    @item = Tourism::Genre.find(params[:id])
    _destroy @item
  end

  def spots(_rendering = true)
    genre = Tourism::Genre
            .published
            .where(id: params[:genre_id])
            .first

    spots = Tourism::Spot
            .published
            .genre_is(genre)
    spots = spots.where(genre_ids: 0) unless genre
    spots = spots.order(:title_kana)
    spots = spots.collect { |i| [i.title, i.id] }

    title = genre ? "#{genre.title}:" : nil
    @items = [["// 一覧を更新しました（#{title}#{spots.size}件）", '']] + spots

    respond_to do |format|
      format.html { render layout: false }
    end
  end
end
