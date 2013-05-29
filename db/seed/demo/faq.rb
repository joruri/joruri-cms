# encoding: utf-8

## ---------------------------------------------------------
## cms/concepts

concept  = create_cms_concept :sort_no => 500, :name => 'FAQ'

## ---------------------------------------------------------
## cms/contents

content = create_cms_content :model => "Faq::Doc", :name => "FAQ"

## ---------------------------------------------------------
## cms/layouts

l_cate = create_cms_layout :name => "faq-category", :title => "FAQ分野", :concept_id => concept.id
l_doc  = create_cms_layout :name => "faq-doc", :title => "FAQ記事ページ", :concept_id => concept.id
l_rec  = create_cms_layout :name => "faq-recent", :title => "FAQ新着一覧", :concept_id => concept.id
l_tag  = create_cms_layout :name => "faq-tag", :title => "FAQタグ検索", :concept_id => concept.id
l_top  = create_cms_layout :name => "faq-top", :title => "FAQトップページ", :concept_id => concept.id

## ---------------------------------------------------------
## cms/pieces

create_cms_piece :concept_id => concept.id, :content_id => content.id, :model => "Faq::Category",
  :name => "faq-category-list", :title => "FAQ分野一覧", :view_title => "分野一覧"
create_cms_piece :concept_id => concept.id, :content_id => content.id, :model => "Faq::RecentDoc",
  :name => "faq-recent-docs", :title => "FAQ新着記事", :view_title => "新着記事"
create_cms_piece :concept_id => concept.id, :content_id => content.id, :model => "Faq::SearchDoc",
  :name => "faq-search", :title => "FAQ検索", :view_title => "FAQ検索"
create_cms_piece :concept_id => concept.id, :model => "Cms::Free", :name => "faq-tel", :title => "コールセンター"
create_cms_piece :concept_id => concept.id, :model => "Cms::Free", :name => "faq-page-title", :title => "ページタイトル"
create_cms_piece :concept_id => concept.id, :model => "Cms::Free", :name => "faq-recent-title", :title => "FAQ新着情報タイトル"

## ---------------------------------------------------------
## cms/nodes

#create_cms_node :layout_id => layout.id, :content_id => content.id, :model => "Newsletter::Form", :name => "mailmagazine", :title => "メールマガジン"

p = create_cms_node :concept_id => concept.id, :layout_id => nil, :model => 'Cms::Directory', :name => 'faq'   , :title => 'FAQ'
    create_cms_node :concept_id => concept.id, :content_id => content.id, :layout_id => l_cate.id, :model => 'Faq::Category', :name => 'bunya', :title => '分野',
      :parent_id => p.id
    create_cms_node :concept_id => concept.id, :content_id => content.id, :layout_id => l_doc.id, :model => 'Faq::Doc', :name => 'docs', :title => '記事',
      :parent_id => p.id
    create_cms_node :concept_id => concept.id, :content_id => content.id, :layout_id => l_rec.id, :model => 'Faq::RecentDoc', :name => 'shinchaku', :title => '新着記事',
      :parent_id => p.id
    create_cms_node :concept_id => concept.id, :content_id => content.id, :layout_id => l_rec.id, :model => 'Faq::SearchDoc', :name => 'search', :title => '新着記事',
      :parent_id => p.id
    create_cms_node :concept_id => concept.id, :content_id => content.id, :layout_id => l_tag.id, :model => 'Faq::TagDoc', :name => 'tag', :title => 'タグ検索',
      :parent_id => p.id
    create_cms_node :concept_id => concept.id, :layout_id => l_top.id, :model => 'Cms::Page'  , :name => 'index.html', :title => 'FAQ',
      :parent_id => p.id , :body => read_data("nodes/faq/index/body")

## ---------------------------------------------------------
## faq/categories

def create(concept, parent, level_no, sort_no, layout, content, name, title)
  Faq::Category.create :concept_id => concept.id,
    :parent_id => (parent == 0 ? 0 : parent.id),
    :level_no => level_no, :sort_no => sort_no, :state => 'public',
    :layout_id => layout.id, :content_id => content.id, :name => name, :title => title
end

p = create concept, 0, 1, 1 , l_cate , content, 'kurashi'          , 'くらし'
    create concept, p, 2, 1 , l_cate , content, 'shohiseikatsu'    , '消費生活'
    create concept, p, 2, 2 , l_cate , content, 'shakaikoken'      , '社会貢献・NPO'
    create concept, p, 2, 3 , l_cate , content, 'bohan'            , '防犯・安全'
    create concept, p, 2, 4 , l_cate , content, 'sumai'            , 'すまい'
    create concept, p, 2, 5 , l_cate , content, 'jinken'           , '人権・男女共同参画'
    create concept, p, 2, 6 , l_cate , content, 'kankyo'           , '環境'
    create concept, p, 2, 7 , l_cate , content, 'zei'              , '税'
    create concept, p, 2, 8 , l_cate , content, 'kosodate'         , '子育て'
    create concept, p, 2, 9 , l_cate , content, 'dobutsu'          , '動物・ペット'
    create concept, p, 2, 10, l_cate , content, 'recycle'          , 'リサイクル・廃棄物'
p = create concept, 0, 1, 2 , l_cate , content, 'fukushi'          , '健康・福祉'
    create concept, p, 2, 1 , l_cate , content, 'kenkou'           , '健康'
    create concept, p, 2, 2 , l_cate , content, 'iryo'             , '医療'
    create concept, p, 2, 3 , l_cate , content, 'koreisha'         , '高齢者・介護'
    create concept, p, 2, 4 , l_cate , content, 'chikifukushi'     , '地域福祉'
    create concept, p, 2, 5 , l_cate , content, 'shogaifukushi'    , '障害福祉'
p = create concept, 0, 1, 3 , l_cate , content, 'kyoikubunka'      , '教育・文化'
    create concept, p, 2, 1 , l_cate , content, 'kyoiku'           , '教育'
    create concept, p, 2, 2 , l_cate , content, 'bunka'            , '文化・スポーツ'
    create concept, p, 2, 3 , l_cate , content, 'seishonen'        , '青少年'
    create concept, p, 2, 4 , l_cate , content, 'shogaigakushu'    , '障害学習'
    create concept, p, 2, 5 , l_cate , content, 'gakko'            , '学校・文化施設'
    create concept, p, 2, 6 , l_cate , content, 'kokusaikoryu'     , '国際交流'
p = create concept, 0, 1, 4 , l_cate , content, 'kanko'            , '観光・魅力'
    create concept, p, 2, 1 , l_cate , content, 'event'            , '観光・イベント'
    create concept, p, 2, 2 , l_cate , content, 'meisho'           , '名所・景観'
    create concept, p, 2, 3 , l_cate , content, 'bussanhin'        , '物産品'
    create concept, p, 2, 4 , l_cate , content, 'taikenspot'       , '体験スポット'
p = create concept, 0, 1, 5 , l_cate , content, 'sangyoshigoto'    , '産業・しごと'
    create concept, p, 2, 1 , l_cate , content, 'shigoto'          , '産業・しごと'
    create concept, p, 2, 2 , l_cate , content, 'koyo'             , '雇用・労働'
    create concept, p, 2, 3 , l_cate , content, 'shogyo'           , '商業・サービス業'
    create concept, p, 2, 4 , l_cate , content, 'kigyoshien'       , '企業支援・企業立地'
    create concept, p, 2, 5 , l_cate , content, 'shigen'           , '資源・エネルギー'
    create concept, p, 2, 6 , l_cate , content, 'johotsushin'      , '情報通信・研究開発・科学技術'
    create concept, p, 2, 7 , l_cate , content, 'kenchiku'         , '建築・土木'
    create concept, p, 2, 8 , l_cate , content, 'shikaku'          , '資格・免許・研修'
    create concept, p, 2, 9 , l_cate , content, 'sangyo'           , '産業'
    create concept, p, 2, 10, l_cate, content, 'kigyo'            , '起業'
    create concept, p, 2, 11, l_cate , content, 'ujiturn'          , 'UJIターン'
    create concept, p, 2, 12, l_cate , content, 'chikikeizai'      , '地域経済'
p = create concept, 0, 1, 6 , l_cate , content, 'gyoseimachizukuri', '行政・まちづくり'
    create concept, p, 2, 1 , l_cate , content, 'gyosei'           , '行政・まちづくり'
    create concept, p, 2, 2 , l_cate , content, 'koho'             , '広報・公聴'
    create concept, p, 2, 3 , l_cate , content, 'gyoseikaikaku'    , '行政改革'
    create concept, p, 2, 4 , l_cate , content, 'zaisei'           , '財政・宝くじ'
    create concept, p, 2, 5 , l_cate , content, 'shingikai'        , '審議会'
    create concept, p, 2, 6 , l_cate , content, 'tokei'            , '統計・監査'
    create concept, p, 2, 7 , l_cate , content, 'jorei'            , '条例・規則'
    create concept, p, 2, 8 , l_cate , content, 'soshiki'          , '組織'
    create concept, p, 2, 9 , l_cate , content, 'jinji'            , '人事・採用'
    create concept, p, 2, 10, l_cate , content, 'nyusatsu'         , '入札・調達'
    create concept, p, 2, 11, l_cate , content, 'machizukuri'      , 'まちづくり・都市計画'
    create concept, p, 2, 12, l_cate , content, 'doro'             , '道路・施設'
    create concept, p, 2, 13, l_cate , content, 'kasen'            , '河川・砂防'
    create concept, p, 2, 14, l_cate , content, 'kuko'             , '空港・港湾'
    create concept, p, 2, 15, l_cate , content, 'denki'            , '電気・水道'
    create concept, p, 2, 16, l_cate , content, 'ikem'             , '意見・募集'
    create concept, p, 2, 17, l_cate , content, 'johokokai'        , '情報公開・個人情報保護'
    create concept, p, 2, 18, l_cate , content, 'johoka'           , '情報化'
    create concept, p, 2, 19, l_cate , content, 'shinsei'          , '申請・届出・行政サービス'
    create concept, p, 2, 20, l_cate , content, 'kokyojigyo'       , '公共事業・公営企業'
p = create concept, 0, 1, 7 , l_cate , content, 'bosaigai'         , '防災'
    create concept, p, 2, 1 , l_cate , content, 'bosai'            , '防災'
    create concept, p, 2, 2 , l_cate , content, 'saigai'           , '災害'
    create concept, p, 2, 3 , l_cate , content, 'kishojoho'        , '気象情報'
    create concept, p, 2, 4 , l_cate , content, 'kotsu'            , '交通'
    create concept, p, 2, 5 , l_cate , content, 'shokunoanzen'     , '食の安全'

## ---------------------------------------------------------
## faq/docs

def create(content_id, category_ids, rel_doc_ids, title, question, body = read_data('docs/002/body'))
  Faq::Doc.create(:content_id => content_id, :state => 'public',
    :recognized_at => Core.now, :published_at => Core.now, :language_id => 1,
    :category_ids => category_ids,:rel_doc_ids => rel_doc_ids,
    :recent_state => 'visible',
    :title => title, :body => body, :question => question)
end

d = create content.id, 5, nil, 'ジョールリ市に移住するので、各種手続きの情報について知りたい。', 'ジョールリ市に移住するので、各種手続きの情報について知りたい。',
  '「ライフイベント」の「引っ越し」に、移住に関する情報をまとめて掲載しております。' + "<br />\n" +
  '「ライフイベント」では人生の節目に起こるさまざまな出来事についてカテゴリ分けし、情報を提供しております。' + "<br />\n" +
  '' + "<br />\n" +
  '・<a href="/lifeevent/">ライフイベント</a>' + "<br />\n" +
  '' + "<br />\n" +
  '・<a href="/lifeevent/hikkoshi.html">ライフイベント-引っ越し</a>' + "<br />\n"

