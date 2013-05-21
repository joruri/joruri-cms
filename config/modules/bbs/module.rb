# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :bbs, '掲示板' do |mod|
  ## contents
  mod.content :items, '掲示板'
  
  ## directory
  mod.directory :threads, '投稿一覧/レス表示形式'
  #mod.directory :trees, '投稿一覧/ツリー表示形式'
  
  ## pages
  #mod.page
  
  ## pieces
  mod.piece :recent_items, '新着投稿一覧'
end
