# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :cms, '標準機能' do |mod|
  ## contents
  ;
  
  ## directory
  mod.directory :directories, 'ディレクトリ'
  
  ## pages
  mod.page :pages, '自由形式'
  mod.page :sitemaps, 'サイトマップ'
  
  ## pieces
  mod.piece :frees, '自由形式'
  mod.piece :page_titles, 'ページタイトル'
  mod.piece :bread_crumbs, 'パンくず'
  mod.piece :links, 'リンク集'
  mod.piece :sns_sharings, 'SNS共有リンク'
end
