# encoding: utf-8

## ---------------------------------------------------------
## cms/contents

content = create_cms_content :model => "Calendar::Event", :name => "年間行事"

Cms::ContentSetting.create :content_id => content.id, :name => "doc_content_id"

def create_calendar_event(params)
  params[:state]        ||= "public"
  params[:published_at] ||= Core.now
  Calendar::Event.create params
end
#
sdate = Date.new(Date.today.year, 1, 1)
0.upto(11) do |i|
  date = sdate >> i
  create_calendar_event :content_id => content.id, :event_date => date.strftime("%Y-%m-#{rand(27)+1}"),
    :title => "○○講演会" if i%4 == 0
  create_calendar_event :content_id => content.id, :event_date => date.strftime("%Y-%m-#{rand(27)+1}"),
    :title => "○○コンサート" if i%4 == 1
  create_calendar_event :content_id => content.id, :event_date => date.strftime("%Y-%m-#{rand(27)+1}"),
    :title => "○○大会" if i%4 == 2
  create_calendar_event :content_id => content.id, :event_date => date.strftime("%Y-%m-#{rand(27)+1}"),
    :title => "○○式典" if i%5 == 0
  create_calendar_event :content_id => content.id, :event_date => date.strftime("%Y-%m-#{rand(27)+1}"),
    :title => "○○まつり" if i%5 == 2
end

## ---------------------------------------------------------
## cms/concept

#concept = Cms::Concept.find_by_name("")

## ---------------------------------------------------------
## cms/layouts

layout = create_cms_layout :name => "calendar", :title => "年間行事"

## ---------------------------------------------------------
## cms/pieces

create_cms_piece :content_id => content.id, :model => "Calendar::MonthlyLink",
  :name => "calendar-monthly-links", :title => "年間行事-月別リンク"
create_cms_piece :content_id => content.id, :model => "Calendar::DailyLink",
  :name => "calendar-daily-links", :title => "年間行事-日別リンク", :view_title => "カレンダー"

## ---------------------------------------------------------
## cms/nodes

create_cms_node :layout_id => layout.id, :content_id => content.id, :model => "Calendar::Event",
  :name => "calendar", :title => "年間行事"

