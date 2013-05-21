# encoding: utf-8
Cms::Lib::Modules::ModuleSet.draw :calendar, 'カレンダーDB' do |mod|
  ## contents
  mod.content :events, 'カレンダー'
  
  ## directory
  mod.directory :events, "イベント一覧"
  
  ## pages
  #mod.page
  
  ## pieces
  mod.piece :monthly_links, "月別リンク"
  mod.piece :daily_links, "日別リンク"
end
