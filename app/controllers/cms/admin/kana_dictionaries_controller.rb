# encoding: utf-8
class Cms::Admin::KanaDictionariesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Publication

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
  end

  def index
    return test if params[:do] == 'test'
    return make_dictionary if params[:do] == 'make_dictionary'

    @items = Cms::KanaDictionary
             .all
             .order(params[:sort], :name, :id)
             .paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end

  def show
    @item = Cms::KanaDictionary.find(params[:id])
    return error_auth unless @item.readable?

    _show @item
  end

  def new
    @item = Cms::KanaDictionary.new(body: '' \
                                        "# コメント ... 先頭に「#」\n" \
                                        "# 辞書には登録されません。\n\n" \
                                        "# 日本語例 ... 「漢字, カタカナ」\n" \
                                        "徳島県, トクシマケン\n\n" \
                                        "# 英字例 ... 「英字, カタカナ」\n" \
                                        "Joruri, ジョールリ\n")
  end

  def create
    return test if params[:do] == 'test'

    @item = Cms::KanaDictionary.new(kana_dictionary_params)
    _create @item
  end

  def update
    @item = Cms::KanaDictionary.find(params[:id])
    @item.attributes = kana_dictionary_params
    _update @item
  end

  def destroy
    @item = Cms::KanaDictionary.find(params[:id])
    _destroy @item
  end

  def make
    res = Cms::KanaDictionary.make_dic_file
    flash[:notice] = if res == true
                       '辞書を更新しました。'
                     else
                       res.join('<br />')
                     end

    redirect_to cms_kana_dictionaries_url
  end

  def kana_dictionary_params
    params.require(:item).permit(
      :name, :body, in_creator: [:group_id, :user_id])
  end
end
