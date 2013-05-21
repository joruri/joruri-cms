# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :portal, '新着記事ポータル' do |mod|
  ## contents
  mod.content :feeds, '新着記事ポータル'

  ## directory
  mod.directory :feed_entries, '新着記事一覧'
  mod.directory :event_entries, 'イベント一覧'
  mod.directory :categories, 'グループ一覧'

  ## pages
  #mod.page

  ## pieces
  mod.piece :feed_entries, '新着記事一覧'
  mod.piece :recent_tabs, '新着タブ'
  mod.piece :calendars, 'カレンダー'
  mod.piece :categories, 'グループ一覧'
end
