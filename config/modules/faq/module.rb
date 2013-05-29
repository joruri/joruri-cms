# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :faq, 'FAQ' do |mod|
  ## contents
  mod.content :docs, 'FAQ'
  
  ## directory
  mod.directory :docs, '記事一覧，記事ページ'
  mod.directory :recent_docs, '新着記事一覧'
  mod.directory :search_docs, '記事検索'
  mod.directory :tag_docs, 'タグ検索'
  mod.directory :categories, '分野一覧'
  
  ## pages
  #mod.page
  
  ## pieces
  mod.piece :recent_docs, '新着記事一覧'
  mod.piece :search_docs, '記事検索フォーム'
  mod.piece :categories, '分野一覧'
end
