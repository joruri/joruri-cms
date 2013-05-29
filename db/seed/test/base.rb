# encoding: utf-8

puts "-- test seed"

test_num   = 1000
test_title = "<s>テストタイトル</s>"
test_text  = %Q(<s>#{"テストメッセージ<br />\n"*2}#{"<!-- コメント --><br />\n"}</s>)

## -------
## user

Core.user = Sys::User.find(1)
Core.user_group = Core.user.groups[0]

## -------
## article

if base = Article::Doc.find(:first)
  1.upto(test_num) do |i|
    flag = (i%3 > 0)
    view_state = flag ? "visible" : "hidden"
    cond = { :content_id => base.content_id }
    cate_ids = Article::Category.find(:all, :conditions => cond, :order => "rand()", :limit => 3).collect{|c| c.id }
    area_ids = Article::Area.find(:all, :conditions => cond, :order => "rand()", :limit => 3).collect{|c| c.id }
    attr_ids = Article::Attribute.find(:all, :conditions => cond, :order => "rand()", :limit => 1).collect{|c| c.id }
    
    doc = base.duplicate
    doc.state          = 'public'
    doc.published_at   = Core.now
    doc.category_ids   = cate_ids.join(" ")
    doc.area_ids       = area_ids.join(" ")
    doc.attribute_ids  = attr_ids.join(" ")
    doc.title          = "[#{doc.id}/#{doc.unid}] #{test_title}";
    doc.body           = "#{test_text}"
    doc.sns_link_state = view_state
    doc.event_state    = view_state
    doc.event_date     = flag ? Date::new(2013, rand(11)+1, rand(27)+1).to_s : nil
    doc.in_inquiry     = {
      "state"        => view_state,
      "group_id"     => Core.user_group.id,
      "charge"       => test_text,
      "tel"          => "000-00-0000",
      "fax"          => "000-00-0000",
      "email"        => "name@example.jp",
    }
    doc.save(:validate => false)
  end
end


## -------
## faq

if base = Faq::Doc.find(:first)
  1.upto(test_num) do |i|
    flag = (i%3 > 0)
    view_state = flag ? "visible" : "hidden"
    cond = { :content_id => base.content_id }
    cate_ids = Faq::Category.find(:all, :conditions => cond, :order => "rand()", :limit => 3).collect{|c| c.id }
    
    doc = base.duplicate
    doc.state          = 'public'
    doc.published_at   = Core.now
    doc.category_ids   = cate_ids.join(" ")
    doc.title          = "[#{doc.id}/#{doc.unid}] #{test_title}";
    doc.body           = "#{test_text}"
    doc.in_inquiry     = {
      "state"        => view_state,
      "group_id"     => Core.user_group.id,
      "charge"       => test_text,
      "tel"          => "000-00-0000",
      "fax"          => "000-00-0000",
      "email"        => "name@example.jp",
    }
    doc.save(:validate => false)
  end
end
