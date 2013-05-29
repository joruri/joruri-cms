# encoding: utf-8

## ---------------------------------------------------------
## cms/contents

content = create_cms_content :model => "Bbs::Item", :name => "掲示板"

## ---------------------------------------------------------
## cms/concept

#concept = Cms::Concept.find_by_name("")

## ---------------------------------------------------------
## cms/layouts

layout = create_cms_layout :name => "bbs", :title => "掲示板"

## ---------------------------------------------------------
## cms/pieces

create_cms_piece :content_id => content.id, :model => "Bbs::RecentItem",
  :name => "bbs-recent-entries", :title => "掲示板-新着投稿一覧", :view_title => "新着投稿"

## ---------------------------------------------------------
## cms/nodes

create_cms_node :layout_id => layout.id, :content_id => content.id, :model => "Bbs::Thread",
  :name => "bbs", :title => "掲示板"

