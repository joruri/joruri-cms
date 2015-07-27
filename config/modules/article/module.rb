# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :article, '自治体記事' do |mod|
  ## contents
  mod.content :docs, '自治体記事'
  
  ## directory
  mod.directory :docs, '記事一覧，記事ページ'
  mod.directory :recent_docs, '新着記事一覧'
  mod.directory :event_docs, 'イベント記事一覧'
  mod.directory :tag_docs, 'タグ検索'
  mod.directory :units, '組織一覧'
  mod.directory :categories, '分野一覧'
  mod.directory :attributes, '属性一覧'
  mod.directory :areas, '地域一覧'
  
  ## pages
  #mod.page
  
  ## pieces
  mod.piece :recent_docs, '新着記事一覧'
  mod.piece :recent_tabs, '新着タブ'
  mod.piece :calendars, 'カレンダー'
  mod.piece :units, '組織一覧'
  mod.piece :categories, '分野一覧'
  mod.piece :attributes, '属性一覧'
  mod.piece :areas, '地域一覧'
end
