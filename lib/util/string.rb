# encoding: utf-8
module Util::String
  def self.search_platform_dependent_characters(str)
    regex = "[" +
      "①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳" +
      "ⅠⅡⅢⅣⅤⅥⅦⅧⅨⅩ㍉㌔㌢㍍㌘㌧㌃㌶㍑㍗" +
      "㌍㌦㌣㌫㍊㌻㎜㎝㎞㎎㎏㏄㎡㍻〝〟№㏍℡㊤" +
      "㊥㊦㊧㊨㈱㈲㈹㍾㍽㍼㍻©®㈷㈰㈪㈫㈬㈭㈮㈯" +
      "㊗㊐㊊㊋㊌㊍㊎㊏㋀㋁㋂㋃㋄㋅㋆㋇㋈㋉㋊㋋" +
      "㏠㏡㏢㏣㏤㏥㏦㏧㏨㏩㏪㏫㏬㏭㏮㏯㏰㏱㏲㏳" +
      "㏴㏵㏶㏷㏸㏹㏺㏻㏼㏽㏾↔↕↖↗↘↙⇒⇔⇐⇑⇓⇕⇖⇗⇘⇙" +
      "㋐㋑㋒㋓㋔㋕㋖㋗㋘㋙㊑㊒㊓㊔㊕㊟㊚㊛㊜㊣" +
      "㊡㊢㊫㊬㊭㊮㊯㊰㊞㊖㊩㊝㊘㊙㊪㈳㈴㈵㈶㈸" +
      "㈺㈻㈼㈽㈾㈿►☺◄☻‼㎀㎁㎂㎃㎄㎈㎉㎊㎋㎌㎍" +
      "㎑㎒㎓ⅰⅱⅲⅳⅴⅵⅶⅷⅸⅹ〠♠♣♥♤♧♡￤＇＂" +
      "]"
    
    chars = []
    if str =~ /#{regex}/
      str.scan(/#{regex}/).each do |c|
        chars << c
      end
    end
    
    chars.size == 0 ? nil : chars.uniq.join('')
  end
end