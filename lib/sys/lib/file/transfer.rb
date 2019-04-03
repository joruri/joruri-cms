# encoding: utf-8
module Sys::Lib::File::Transfer
  require "rsync"

  def transfer_files(options={})
    load_transfer_settings

    if @dest_dir.blank?
      rsync_log "[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] transfer_dest_dir setting is blank." if _logging
      return nil
    end

    # options
    _logging = @log
    _trial   = options.has_key?(:trial) ? options[:trial] : false;
    _user_id = options[:user] || Core.user.id rescue nil;
    _sites   = options[:sites] || Cms::Site.where(:state => 'public').order(:id)

    @version = Time.now.to_i

    result = {:version => @version, :common => {}, :sites => {} }

    rsync_log "[#{@version}] rsync start (#{Time.now.strftime('%Y-%m-%d %H:%M:%S')})" if _logging

    dest_addr = @dest_dir
    dest = if @dest_user.to_s != '' && @dest_host.to_s != ''
      dest_addr = "#{@dest_user}@#{@dest_host}:#{@dest_dir}"
      @opt_remote_shell ? "-e \"#{@opt_remote_shell}\" #{dest_addr}" : dest_addr;
    else
      dest_addr
    end

    _ready_options = lambda do |include_file, file_base|
      options = []
      options << "-n" if _trial
      if include_file
        options << "--include-from=#{include_file.path}"
      end
      options << @opts if @opts
      return options
    end

    _rsync = lambda do |src, dest, command_opts|
      rsync(src, dest, command_opts) do |res|
        return res unless _logging

        if res.success?
          res.changes.each do |change|
            update_type = change.update_type
            file_type   = change.file_type
            next if update_type == :no_update
            operation = if ([:sent, :recv].include?(update_type) && change.timestamp == :new) ||
              (file_type == :directory && update_type == :change)
              :create
            elsif update_type == :message && change.summary == 'deleting'
              :delete
            elsif [change.checksum, change.size, change.timestamp].include?(:changed)
              :update
            else
              update_type
            end
            rsync_log "[#{@version}] [#{operation}] #{src}#{change.filename}"
          end
        else
          rsync_log "[#{@version}] #{res.error}" if _logging
        end

        res
      end
    end

    # common directory rsync
    common_src = "#{Rails.root}/public/"
    upload_src = "#{Rails.root}/upload/"

    options = _ready_options.call(nil, 'common')
    result[:common]['public'] = _rsync.call(common_src, "#{dest}public/", options).error
    options = _ready_options.call(nil, 'upload')
    result[:common]['upload'] = _rsync.call(upload_src, "#{dest}upload/", options).error

    # dictionary rsync
    dic_src  = "#{Rails.root}/config/mecab/"
    dic_dest = "#{dest}config/mecab/"
    options = _ready_options.call(nil, 'dic')
    result[:common]['dic'] = _rsync.call(dic_src, dic_dest, options).error

    # rewrite directory rsync
    dic_src  = "#{Rails.root}/config/rewrite/"
    dic_dest = "#{dest}config/rewrite/"
    options = _ready_options.call(nil, 'dic')
    result[:common]['rewrite'] = _rsync.call(dic_src, dic_dest, options).error

    _sites.each do |site|
      site = Cms::Site.find_by_id(site) if site.is_a?(Integer)
      result[:sites][site.id] = []

      # sync
      site_src   = "#{site.public_path}/"
      site_dest  = site_src.gsub(/^#{Rails.root}/, dest)

      options = _ready_options.call(nil, 'site')
      result[:sites][site.id] << _rsync.call(site_src, site_dest, options).error

    end

    rsync_log "[#{@version}] ...end(#{Time.now.strftime('%Y-%m-%d %H:%M:%S')})" if _logging

    result
  rescue => e
    if _logging
      rsync_log "[#{@version}] Error: #{e}"
      rsync_log "[#{@version}] ...end(#{Time.now.strftime('%Y-%m-%d %H:%M:%S')})"
    end
    nil
  end

  def transfer_to_publish?
    conf = Util::Config.load(:rsync)
    return conf['transfer_to_publish']
  end

protected
  def load_transfer_settings
    conf = Util::Config.load(:rsync)
    @log              = conf['transfer_log']
    @opts             = conf['transfer_opts']
    @opt_remote_shell = conf['transfer_opt_remote_shell']
    @dest_user        = conf['transfer_dest_user']
    @dest_host        = conf['transfer_dest_host']
    @dest_dir         = conf['transfer_dest_dir']
  end

  def rsync_log(data)
    log = "#{Rails.root}/log/rsync.log"
    f = ::File.open(log, 'a')
    f.puts "#{data.force_encoding('utf-8')}"
    f.close
  end

  def rsync(src, dest, options=[], &block)
    res = Rsync.run(src, dest, options)
    yield(res) if block_given?
    res
  end
end
