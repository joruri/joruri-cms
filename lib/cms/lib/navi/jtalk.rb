# encoding: utf-8
class Cms::Lib::Navi::Jtalk
  
  def self.make_text(html)
    require 'MeCab'
    require "cgi"
    
    ## settings
    mecab_rc = Cms::KanaDictionary.mecab_rc
    
    ## trim
    html.gsub!(/(\r\n|\r|\n)+/, " ")
    if html =~ /<div [^>]*?id="content"/i
      html.gsub!(/.*?<div [^>]*?id="content".*?>(.*)<!-- end #content --><\/div>.*/i, '\\1')
    end
    if html =~ /<body/i
      html.gsub!(/.*<body.*?>(.*)<\/body.*/i, '\\1')
    end
    if html =~ /<!-- skip.reading -->/
      html.gsub!(/.*<!-- skip.reading -->(.*?)<!-- \/skip.reading -->.*/i, '\\1')
    end
    ["style", "script", "noscript", "iframe", "rb", "rp"].each do |name|
      html.gsub!(/<#{name}.*?>.*?<\/#{name}>/i, '') if html =~ /<#{name}/
    end
    
    ## img
    html.gsub!(/<img .*?>/i) do |m|
      alt = nil
      alt = m.sub(/.* title="(.*?)".*/i, '\\1') if m =~ / title=".*?"/
      alt = m.sub(/.* alt="(.*?)".*/i, '\\1') if m =~ / alt=".*?"/
      alt ? "画像 #{alt}" : ""
    end

    html.gsub!(/<\/(h1|h2|h3|h4|h5|p|div|pre|blockquote|ul|ol)>/i, "。")
    html.gsub!(/<\/?[a-z!][^>]*>/i, "")
    
    html = CGI::unescapeHTML(html)
    html.gsub!("&nbsp;", " ")
    html.gsub!(/[\s\t\v\n、，　「」【】（）\(\)<>\[\]]+/, " ")
    html.gsub!(/\s*。+\s*/, "。")
    html.gsub!(/。+/, "。")
    html.tr!('０-９ａ-ｚＡ-Ｚ', '0-9a-zA-Z')
    html.gsub!(/^[、。 ]+/, "")
    html.gsub!(/[、。]+$/, "")
    
    texts = []
    
    mc = MeCab::Tagger.new('--node-format=%c,%M,%H\n -r ' + mecab_rc)
    mc.parse(html).split(/\n/).each_with_index do |line, line_no|
      p = line.split(/,/)
      next if line == "EOS"
      
      cost = p[0]
      word = p[1]
      kana = p[9]
      
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
  
  def make(*args)
    ## settings
    sox         = Joruri.config[:cms_sox_bin]
    lame        = Joruri.config[:cms_lame_bin]
    talk_bin    = Joruri.config[:cms_talk_bin]
    talk_voice  = Joruri.config[:cms_talk_voice]
    talk_dic    = Joruri.config[:cms_talk_dic]
    talk_opts   = Joruri.config[:cms_talk_opts]
    talk_strlen = Joruri.config[:cms_talk_strlen].to_i
    
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
    parts = []
    buf   = ""
    
    self.class.make_text(text).split(/[ 。]/).each do |str|
      buf << " " if !buf.blank?
      buf << str
      if buf.size >= talk_strlen
        texts << buf
        buf = ""
      end
    end
    texts << buf
    
    ## split
    texts.each do |text|
      cnf = Tempfile::new(["talk", ".cnf"], '/tmp')
      wav = Tempfile::new(["talk", ".wav"], '/tmp')
      
      cnf.puts(text.strip)
      cnf.close
      
      cmd = "#{talk_bin} -m #{talk_voice} -x #{talk_dic} #{talk_opts}"
      system("#{cmd} -ow #{wav.path} #{cnf.path}")
      
      if FileTest.exists?(wav.path)
        parts << wav
      end
      FileUtils.rm(cnf.path) if FileTest.exists?(cnf.path)
    end
    
    wav = Tempfile::new(["talk", ".wav"], '/tmp')
    mp3 = Tempfile::new(["talk", "mp3"], '/tmp')
    
    cmd = "#{sox} #{parts.collect{|c| c.path}.join(' ')} #{wav.path}"
    system(cmd)
    
    cmd = "#{lame} --scale 5 --silent #{wav.path} #{mp3.path}"
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
  
end
