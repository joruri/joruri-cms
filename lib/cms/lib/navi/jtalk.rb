# encoding: utf-8
require "cgi"
require "kconv"
class Cms::Lib::Navi::Jtalk

  def make(*args)

    ## settings
    sox         = Joruri.config[:cms_sox_bin]
    lame        = Joruri.config[:cms_lame_bin]
    lame_opts   = Joruri.config[:cms_lame_opts]
    talk_bin    = Joruri.config[:cms_talk_bin]
    talk_voice  = Joruri.config[:cms_talk_voice]
    talk_dic    = Joruri.config[:cms_talk_dic]
    talk_opts   = Joruri.config[:cms_talk_opts]
    talk_strlen = Joruri.config[:cms_talk_strlen].to_i
    talk_thread_num = Joruri.config[:cms_talk_thread_num].to_i

    text    = nil
    options = {}

    if args[0].class == String
      text    = args[0]
      options = args[1] || {}
    elsif args[0].class == Hash
      options = args[0]
    end

    if options[:uri]
      options[:uri].sub!(/\/index\.html$/, '/')
      res = Util::Http::Request.get(options[:uri])
      text = res.status == 200 ? res.body : nil
    end
    return false unless text

    texts = []
    buf   = ""

    site_id = options[:site_id] rescue nil

    text = self.class.make_text(text, site_id)
    return false if text.blank?

    text.split(/[ 。]/).each do |str|
      buf << " " if buf.present?
      buf << str
      if buf.size >= talk_strlen
        texts << buf
        buf = ""
      end
    end
    texts << buf if buf.present?

    ## split
    parts = []
    Parallel.each_with_index(texts, in_threads: talk_thread_num) do |text, i|
      cnf = Tempfile::new(["talk", ".cnf"], '/tmp')
      wav = Tempfile::new(["talk", ".wav"], '/tmp')

      cnf.puts(text.strip)
      cnf.close

      cmd = "#{talk_bin} -m #{talk_voice} -x #{talk_dic} #{talk_opts}"
      system("#{cmd} -ow #{wav.path} #{cnf.path}")

      if FileTest.exists?(wav.path)
        parts[i] = wav
      end
      FileUtils.rm(cnf.path) if FileTest.exists?(cnf.path)
    end

    wav = Tempfile::new(["talk", ".wav"], '/tmp')
    mp3 = Tempfile::new(["talk", "mp3"], '/tmp')

    cmd = "#{sox} #{parts.compact.map(&:path).join(' ')} #{wav.path}"
    system(cmd)

    cmd = "#{lame} #{lame_opts} #{wav.path} #{mp3.path}"
    system(cmd)

    parts.each do |part|
      FileUtils.rm(part.path) if FileTest.exists?(part.path)
    end
    FileUtils.rm(wav.path) if FileTest.exists?(wav.path)

    @mp3 = mp3
  end

  def output
    if @mp3 && FileTest.exists?(@mp3.path)
      return {:path => @mp3.path, :mime_type => 'audio/mp3'}
    end
    return nil
  end

  class << self
    def make_text(html, site_id = nil)
      text = html_to_text(html)
      apply_kana_dic(text, site_id)
    end

    private

    def html_to_text(html)
      doc = Nokogiri::HTML(html.toutf8, nil, 'utf-8')

      content = doc.css('div[@id="content"]').first || doc.css('body').first || doc.root
      return '' unless content

      content.xpath('.//comment()[.=" skip reading "]').each do |comment1|
        comment2 = comment1.xpath('following-sibling::comment()[.=" /skip reading "]').first
        nodes_between(comment1.parent, comment1, comment2).each(&:remove) if comment2 && comment1.parent
      end

      ## replace img tag
      content.css('img').each do |img|
        if alt = img['alt'].presence || img['title'].presence
          img.replace(Nokogiri::XML::Text.new("画像 #{alt}", doc))
        else
          img.remove
        end
      end

      ## remove unnecessary tags
      content.css('style, script, noscript, iframe, rb, rp').remove

      ## make end of sentence
      content.css('h1, h2, h3, h4, h5, p, div, pre, blockquote, ul, ol').each do |node|
        node.next = Nokogiri::XML::Text.new('。', doc)
      end

      ## convert to text
      html = content.text

      ## trim
      html.gsub!(/(\r\n|\r|\n)+/, " ")
      html.gsub!(/[\s\t\v\n、，　「」【】（）\(\)<>\[\]]+/, " ")
      html.gsub!(/\s*。+\s*/, "。")
      html.gsub!(/。+/, "。")
      html.tr!('０-９ａ-ｚＡ-Ｚ', '0-9a-zA-Z')
      html.gsub!(/^[、。 ]+/, "")
      html.gsub!(/[、。]+$/, "")
      html
    end

    def nodes_between(parent, first, last)
      p1 = parent.children.index(first)
      p2 = parent.children.index(last)
      p1 && p2 ? parent.children[p1..p2] : []
    end

    def apply_kana_dic(text, site_id = nil)
      require 'MeCab'
      mecab_rc = Cms::KanaDictionary.mecab_rc
      mc = MeCab::Tagger.new('--node-format=%c,%M,%f[7]\n --unk-format=%c,%M\n --eos-format= -r ' + mecab_rc)

      texts = []
      mc.parse(text).split("\n").each do |line|
        cost, word, kana = line.split(",")

        if !kana || kana == "*" || cost != "100"
          texts << word # skip
        elsif word == kana.tr('ァ-ン', 'ぁ-ん')
          texts << word
        else
          texts << kana
        end
      end
      texts.join
    end
  end
end
