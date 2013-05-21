# encoding: utf-8
class Cms::KanaDictionary < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Sys::Model::Auth::Manager
  
  validates_presence_of :name
  
  before_save :convert_csv
  
  def self.mecab_rc
    user_dic # confirm
    return "#{Rails.root}/config/mecab/mecabrc"
  end
  
  def self.user_dic
    dic = "#{Rails.root}/config/mecab/joruri.dic"
    
    if ::File.exists?(dic)
      return dic 
    elsif ::Storage.exists?(dic)
      ::File.binwrite(dic, ::Storage.read(dic))
    else
      FileUtils.cp("#{dic}.original", dic)
    end
    return dic
  end
  
  def self.dic_mtime
    pkey = "mecab_dic_mtime"
    return Core.config[pkey] if Core.config[pkey]
    
    file = user_dic
    return Core.config[pkey] = ::File.mtime(file)
  end
  
  def convert_csv
    csv = []
    
    body.split(/(\r\n|\n)/u).each_with_index do |line, idx|
      line = line.to_s.gsub(/#.*/, "")
      line.strip!
      next if line.blank?
      
      data = line.split(/\s*,\s*/)
      word = data[0].strip
      kana = data[1].strip.tr("ぁ-ん", "ァ-ン")
      hira = kana.tr("ァ-ン", "ぁ-ん")
      
      errors.add :base, "フォーマットエラー: #{line} (#{idx+1}行目)" if !data[1] || data[2]
      errors.add :base, "フォーマットエラー: #{line} (#{idx+1}行目)" if kana !~ /^[ァ-ンー]+$/
      return false if errors.size > 0
      
      csv << "#{word},*,*,100,名詞,固有名詞,*,*,*,*,#{hira},#{kana},#{kana}"
    end
    
    self.mecab_csv = csv.join("\n")
    
    return true
  end
  
  def self.make_dic_file
    mecab_index = Joruri.config[:cms_mecab_index]
    mecab_dic   = Joruri.config[:cms_mecab_dic]
    
    errors = []
    data   = []
    
    self.find(:all, :order => "id").each do |item|
      if item.mecab_csv == nil
        data << item.mecab_csv if item.convert_csv == true
        next 
      end
      data << item.mecab_csv if !item.mecab_csv.blank?
    end
    
    if data.blank?
      errors << "登録データが見つかりません。"
      return errors.size > 0 ? errors : true
    end
    
    csv = Tempfile::new(["mecab", ".csv"], '/tmp')
    csv.puts(data.join("\n"))
    csv.close
    
    dic = user_dic
    
    require "shell"
    sh = Shell.new
    sh.transact do
      res = system("#{mecab_index} -d#{mecab_dic} -u #{dic} -f utf8 -t utf8 #{csv.path}").to_s.strip
      errors << "辞書の作成に失敗しました" unless res =~ /done!$/
      
      if Storage.env != :file
        ::Storage.mkdir_p ::File.dirname(dic)
        ::Storage.binwrite dic, ::File.read(dic)
      end
    end
    
    FileUtils.rm(csv.path) if FileTest.exists?(csv.path)
    
    return errors.size > 0 ? errors : true
  end
end
