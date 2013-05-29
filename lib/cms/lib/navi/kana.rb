# encoding: utf-8
class Cms::Lib::Navi::Kana
  
  def self.convert(str)
    return nil unless Joruri.config[:cms_use_kana]
    
    require 'MeCab'
    
    mecab_rc = Cms::KanaDictionary.mecab_rc
    
    str = str.to_utf8.gsub(/\r\n/, "\n")
    
    tmp = str.gsub(/[\r\n]/, "*")
    ["head", "style", "script", "ruby"].each do |name|
      tmp = tmp.gsub(/<#{name}[^>]*>.*?<\/#{name}>/im) {|m| m.gsub(/[\x20-\x7E\r\n\s]/, '*').gsub(/[^\*]/, '...') }
    end
    tmp = tmp.gsub(/<[^>]+>/) {|m| m.gsub(/[\x20-\x7E\r\n\s]/, '*').gsub(/[^\*]/, '...') }
    
    bytes = str.unpack("C*")
    texts = []
    pos   = 0
    
    mc = MeCab::Tagger.new('--node-format=%ps,%pe,%M,%H\n -r ' + mecab_rc)
    mc.parse(tmp).split(/\n/).each_with_index do |line, line_no|
      p = line.split(/,/)
      next if line == "EOS"
      next if p[0] !~ /^[0-9]+$/
      next if p[2] =~ /^[\*\.]+$/
      next if p[10].blank? 
      next if p[10] == "*"
      next if p[2] == p[10]
      next if p[2] !~ /[一-龠]/
      kana = p[10].to_s.tr('ァ-ン', 'ぁ-ん')
      next if p[2] == kana
      
      s = p[0].to_i
      e = p[1].to_i
      
      texts << bytes.slice(pos..s-1).pack("C*").force_encoding('utf-8') if pos < s
      
      word = bytes.slice(s..e-1).pack("C*").force_encoding('utf-8')
      texts << "<ruby><rb>#{word}</rb><rp>(</rp><rt>#{kana}</rt><rp>)</rp></ruby>"
      
      pos = e
    end
    
    texts << bytes.slice(pos..-1).pack("C*").force_encoding('utf-8') if pos < bytes.size
    texts.join.html_safe
  end
  
  # def self.slice(str, start, length)
    # "#{str}".force_encoding('ascii').slice(start, length).to_s.force_encoding('utf-8')
  # end
end
