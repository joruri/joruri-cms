# encoding: utf-8

## ---------------------------------------------------------
## cms/contents

portal = create_cms_content :model => 'Portal::Feed', :name => '新着記事ポータル'
Cms::ContentSetting.create(:content_id => portal.id, :name => 'doc_content_id', :value => 1)

## ---------------------------------------------------------
## cms/feeds

def create(content, name, uri, title, count)
  Cms::Feed.create :content_id => content.id, :state => 'public',
    :name => name, :uri => uri, :title => title, :entry_count => count
end

#create portal, 'tokushimaken', 'http://www.pref.tokushima.jp/shinchaku/index.atom', '徳島県', 50

## ---------------------------------------------------------
## cms/layouts

l_portal = create_cms_layout :name => 'group-portal', :title => 'グループ一覧-ポータル'

## ---------------------------------------------------------
## portal/categories

def create(parent, level_no, sort_no, layout, content, name, title, categories)
  Portal::Category.create :parent_id => (parent == 0 ? 0 : parent.id),
    :level_no => level_no, :sort_no => sort_no, :state => 'public',
    :layout_id => layout.id, :content_id => content.id, :name => name, :title => title,
    :entry_categories => categories
end

p = create 0, 1, 1 , l_portal , portal, 'event'    , '観光・イベント' , "分野/観光・魅力\n分野/観光\n属性/イベント情報"
p = create 0, 1, 2 , l_portal , portal, 'saiyo'    , '採用情報・募集' , "属性/採用情報"
p = create 0, 1, 3 , l_portal , portal, 'nyusatsu' , '入札情報'       , "属性/入札・調達・売却・契約"
p = create 0, 1, 4 , l_portal , portal, 'bosai'    , '防災'           , "分野/防災"

## ---------------------------------------------------------
## cms/pieces

create_cms_piece :content_id => portal.id, :model => 'Portal::Category',
  :name => 'group-portal'   , :title => 'グループ一覧-ポータル', :view_title => "グループ一覧"
create_cms_piece :content_id => portal.id, :model => 'Portal::RecentTab', :concept_id => 2,
  :name => 'doc-tab-portal' , :title => '新着タブポータル'
create_cms_piece :content_id => portal.id, :model => 'Portal::RecentTab', :concept_id => 2,
  :name => 'smart-doc-tab-portal' , :title => 'スマートフォン：新着タブポータル'

## ---------------------------------------------------------
## cms/nodes

l_recent = Cms::Layout.find_by_name('recent')
create_cms_node :layout_id => l_recent.id, :content_id => portal.id, :model => 'Portal::FeedEntry', :name => 'shinchaku-portal', :title => '新着記事-ポータル'
create_cms_node :layout_id => l_portal.id, :content_id => portal.id, :model => 'Portal::Category' , :name => 'group-portal'    , :title => 'グループ一覧-ポータル'
