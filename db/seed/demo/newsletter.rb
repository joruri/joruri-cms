# encoding: utf-8

## ---------------------------------------------------------
## cms/contents

content = create_cms_content :model => "Newsletter::Doc", :name => "メールマガジン"

Cms::ContentSetting.create(:content_id => content.id, :name => "template_state",
  :value => "disabled")
Cms::ContentSetting.create(:content_id => content.id, :name => "sender_address",
  :value => "magazine@example.jp")
Cms::ContentSetting.create(:content_id => content.id, :name => "summary",
  :value => %Q(<p>「ジョールリ市メールマガジン」は、ジョールリ市が発行するメールマガジンです。</p><p>市政の動きやイベント情報などを配信しています。</p><p>毎週金曜日発行です。</p><p>&nbsp;</p><p><span style="color: #ff0000;">※このメールマガジンはサンプルです</span></p>))
Cms::ContentSetting.create(:content_id => content.id, :name => "addition_body",
  :value => %Q(<p>下記のフォームより登録できます。</p><p>メールアドレスを入力し、メール種別を選択してください。</p>))
Cms::ContentSetting.create(:content_id => content.id, :name => "deletion_body",
  :value => %Q(<p>配信を解除するメールアドレスを入力してください。</p>))
Cms::ContentSetting.create(:content_id => content.id, :name => "sent_addition_body",
  :value => %Q(<p>メールマガジンの登録を受け付けました。</p><p>&nbsp;</p><p>後ほど、ご登録のメールアドレス宛に「登録完了のお知らせ」をお送りいたします。</p><p>ご登録ありがとうございました。</p>))
Cms::ContentSetting.create(:content_id => content.id, :name => "sent_deletion_body",
  :value => %Q(<p>メールマガジンの解除を受け付けました。</p><p>&nbsp;</p><p>後ほど、ご登録のメールアドレス宛に「解除完了のお知らせ」をお送りいたします。</p><p>ご利用ありがとうございました。</p>))

## ---------------------------------------------------------
## cms/concept

concept = Cms::Concept.find_by_name("トップページ")

## ---------------------------------------------------------
## cms/layouts

layout = create_cms_layout :name => "mailmagazine", :title => "メールマガジン"

## ---------------------------------------------------------
## cms/pieces

create_cms_piece :content_id => content.id, :model => "Cms::Free", :name => "bn-mailmagazine", :title => "メールマガジン", :concept_id => concept.id

## ---------------------------------------------------------
## cms/nodes

create_cms_node :layout_id => layout.id, :content_id => content.id, :model => "Newsletter::Form", :name => "mailmagazine", :title => "メールマガジン"
