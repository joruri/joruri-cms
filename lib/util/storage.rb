# encoding: utf-8
module Util::Storage
  
  def self.get_table_symbol
    Storage::File    
  end

  #=============================================
  #モジュールのインタフェース
  #=============================================
  #データのDB保存
  # path :キーとなるファイルパス
  # data :データの実体(binary)
  # b_restore ：true/pathにファイル出力する。false/DB保存だけ
  def self.store(path, data, b_restore=true)
    begin
      rc = Record.create(path)
      raise "Can't create record" unless rc

      rc.data = data
      rc.update
      #DB保存と同時にファイル保存も行う
      _restore(path, data) if b_restore

    rescue => e
      dump("Util::Storage::store #{e.message}")
      
    ensure
      ;
    end

    return rc ? rc.id : nil
  end
    
  #データの展開
  def self.restore(path)
    _restore(path, Record.create(path).data)
  end

  #データの取得
  def self.read(path)
    return Record.create(path).data
  end

  #データのコピー的展開
  #srcをDB保存していたら、その内容をdstに展開する
  def self.copy(src, dst)
      rc = Record.create(src)
      return false if rc.new_record?
    
      dst_rc = Record.create(dst)
      dst_rc.data = rc.data
      dst_rc.update
      _restore(dst, rc.data)
      
      return true
  end
  
  #データのDBからの削除
  def self.destroy(path, b_remove_path=true)
    begin
      rc = Record.create(path)
      rc.destroy
  
      #ファイルも削除する
      remove_path(rc.path) if b_remove_path
      
    rescue => e
      dump("Storage::Files::destroy #{e.message}")
      
    ensure
      ;
    end
  end
 
  #指定のパス以下を再帰的に削除
  def self.remove_path(path)
    FileUtils.remove_entry(path)
  end
  
private
 
  #指定のパスにDBのデータを展開する
  def self._restore(path, data)
    dir = File.dirname(path)
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    File.open(path, 'wb') { |f|
      f.write(data)
    }
  end

  #=============================================
  #モジュール内のDBアクセスクラス
  #=============================================
  class Record
    def initialize(path)
      @@storage = Util::Storage.get_table_symbol
      @rc = @@storage.find_by_path(path)
      @path = path
      @data = @rc.data if @rc
    end
    attr_accessor  :path, :data
    
    def self.create(path)
      return Record.new(path)
    end

    def id
      return @rc.id
    end

    def new_record?
      return @rc.new_record?
    end

    def destroy
      @rc.destroy
    end
    
    def update
      if @rc
        @rc.path = @path
        @rc.data = @data
        @rc.save!
      else
        @rc = @@storage.create!(:path => @path, :data => @data)
      end
    end
  end
end
