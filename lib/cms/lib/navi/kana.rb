# encoding: utf-8
class Cms::Lib::Navi::Kana

  class << self
    def convert(html, site_id = nil)
      return nil unless Joruri.config[:cms_use_kana]

      html = html.to_utf8.gsub(/\r\n/, "\n")
      tmp = mask_html(html)

      texts = []
      pos   = 0

      require 'MeCab'
      mecab_rc = Cms::KanaDictionary.mecab_rc
      mc = MeCab::Tagger.new('--node-format=%ps,%pe,%m,%f[7]\n --unk-format= --eos-format= -r ' + mecab_rc)
      mc.parse(tmp).split("\n").each do |line|
        s, e, word, kana = line.split(",")
        next if s !~ /^[0-9]+$/
        next if word !~ /[一-龠]/
        next if kana.blank?

        s = s.to_i
        e = e.to_i
        kana = kana.to_s.tr('ァ-ン', 'ぁ-ん')

        texts << html.byteslice(pos..s-1) if pos < s
        texts << "<ruby><rb>#{word}</rb><rp>(</rp><rt>#{kana}</rt><rp>)</rp></ruby>"

        pos = e
      end

      texts << html.byteslice(pos..-1) if pos < html.bytesize
      texts.join.html_safe
    end

    private

    def mask_html(html)
      mask = lambda {|s| '*' * s.bytesize }

      tmp = html.gsub(/[\r\n]/, &mask)

      ["head", "style", "script", "ruby"].each do |name|
        tmp.gsub!(/<#{name}[^>]*>.*?<\/#{name}>/im, &mask)
      end

      tmp.gsub!(/<[^>]+>/, &mask) || tmp
    end
  end
end
