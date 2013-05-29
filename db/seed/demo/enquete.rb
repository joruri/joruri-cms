# encoding: utf-8

## ---------------------------------------------------------
## cms

content = create_cms_content :model => 'Enquete::Form', :name => 'アンケート'

layout  = create_cms_layout :name => "enquete", :title => "アンケート"

node    = create_cms_node :content_id => content.id, :layout_id  => layout.id,
  :model => "Enquete::Form", :name  => "inquiry", :title => "ジョールリ市へのお問い合わせ", :body  => ""

## ---------------------------------------------------------
## enquete

form = Enquete::Form.create :content_id => content.id, :state => 'public', :sort_no => 1,
  :name      => %Q(ジョールリ市へのお問い合わせ),
  :body      => %Q(<p>ジョールリ市へのお問い合わせは下記のフォームに必要事項を入力の上、ページ下部の「確認する」ボタンを押してください。<br />赤字で「※」がついている項目は、必ずご記入ください。<br /><br /><span style="color: #ff0000;">※このアンケートはサンプルです。</span></p>),
  :summary   => %Q(<p>ジョールリ市へのお問い合わせフォームです。</p>),
  :sent_body => %Q(<p>お問い合わせ内容の送信が完了致しました。</p>)

Enquete::FormColumn.create :form_id => form.id, :state => 'public', :sort_no => 1,
  :name         => "氏名",
  :body         => "<p>氏名を入力してください。</p>",
  :column_type  => "text_field", :column_style => "", :required => 1,
  :options      => nil

Enquete::FormColumn.create :form_id => form.id, :state => 'public', :sort_no => 2,
  :name         => "企業・団体名",
  :body         => "<p>企業・団体名を入力してください。</p>",
  :column_type  => "text_field", :column_style => "width: 300px;", :required => 0,
  :options      => nil

Enquete::FormColumn.create :form_id => form.id, :state => 'public', :sort_no => 3,
  :name         => "メールアドレス",
  :body         => "<p>お問い合わせへの返信に使用させていただきます。</p>",
  :column_type  => "text_field", :column_style => "width: 300px;", :required => 1,
  :options      => nil

Enquete::FormColumn.create :form_id => form.id, :state => 'public', :sort_no => 4,
  :name         => "都道府県",
  :body         => "<p>お住まいの都道府県を選択してください。</p>",
  :column_type  => "select", :column_style => "", :required => 1,
  :options      => "北海道\n青森県\n岩手県\n宮城県\n秋田県\n山形県\n福島県\n茨城県\n栃木県\n群馬県\n埼玉県\n千葉県\n東京都\n神奈川県\n新潟県\n富山県\n石川県\n福井県\n山梨県\n長野県\n岐阜県\n静岡県\n愛知県\n三重県\n滋賀県\n京都府\n大阪府\n兵庫県\n奈良県\n和歌山県\n鳥取県\n島根県\n岡山県\n広島県\n山口県\n徳島県\n香川県\n愛媛県\n高知県\n福岡県\n佐賀県\n長崎県\n熊本県\n大分県\n宮崎県\n鹿児島県\n沖縄県"

Enquete::FormColumn.create :form_id => form.id, :state => 'public', :sort_no => 5,
  :name         => "年代",
  :body         => "<p>年代を選択してください。</p>",
  :column_type  => "radio_button", :column_style => "", :required => 1,
  :options      => "20歳未満\n20～30歳代\n40～50歳代\n60歳以上"

Enquete::FormColumn.create :form_id => form.id, :state => 'public', :sort_no => 6,
  :name         => "お問い合わせ区分",
  :body         => "<p>お問い合わせ内容の区分を選択してください。（複数回答可）</p>",
  :column_type  => "check_box", :column_style => "", :required => 1,
  :options      => "市政について\n申請について\nイベントについて\nその他"

Enquete::FormColumn.create :form_id => form.id, :state => 'public', :sort_no => 7,
  :name         => "お問い合わせ内容",
  :body         => "<p>お問い合わせの具体的な内容を入力してください。</p>  ",
  :column_type  => "text_area", :column_style => "width: 600px;height: 100px;", :required     => 1,
  :options      => nil
