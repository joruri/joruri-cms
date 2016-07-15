# encoding: utf-8
class Newsletter::Admin::MembersController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    @content = Cms::Content.find(params[:content])
    return error_auth unless @content
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    return export_csv if params[:do] == 'csv'

    @items = Newsletter::Member
             .where(content_id: @content.id)
             .search(params)
             .order(params[:sort], updated_at: :desc)
             .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Newsletter::Member.find(params[:id])
    _show @item
  end

  def new
    @item = Newsletter::Member.new(state: 'enabled',
                                   letter_type: 'pc_text')
  end

  def create
    @item = Newsletter::Member.new(member_params)
    @item.content_id = @content.id

    _create @item
  end

  def update
    @item = Newsletter::Member.find(params[:id])
    @item.attributes = member_params

    _update(@item)
  end

  def destroy
    @item = Newsletter::Member.find(params[:id])
    _destroy @item
  end

  protected

  def export_csv
    require 'nkf'
    require 'csv'

    items = Newsletter::Member
            .where(content_id: @content.id)
            .order(:id)

    csv = CSV.generate do |csv|
      csv << %w(登録日時 メールアドレス メール種別 状態)

      items.each do |item|
        row = []
        row << item.created_at.to_s(:db)
        row << item.email
        row << item.letter_type_name
        row << (item.status ? item.status.name : '')
        csv << row
      end
    end

    csv = NKF.nkf('-s', csv)
    send_data csv, type: 'text/csv', filename: "#{::File.basename(params[:controller])}_#{Time.now.to_i}.csv"
  end

  private

  def member_params
    params.require(:item).permit(:state, :email, :letter_type)
  end
end
