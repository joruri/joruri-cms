# encoding: utf-8
class Script
  cattr_reader :options

  def self.run_from_web(path, options = {})
    ## reset
    if proc = Sys::Process.find(:first, conditions: { name: path })
      raise "プロセスが既に実行されています。" if proc.state == 'running'
      proc.attributes = {
        state: nil,
        user_id: Core.user.id,
        started_at: nil,
        closed_at: nil,
        interrupt: nil,
        total: 0,
        current: 0,
        success: 0,
        error: 0,
        message: nil
      }
      proc.save
    end

    ## run
    ruby   = "#{Config::CONFIG['bindir']}/ruby"
    runner = "#{Rails.root}/script/rails runner"
    opts   = options.inspect
    cmd    = "#{ruby} #{runner} -e #{Rails.env} \"Script.run('#{path}', #{opts})\""
    system("#{cmd} >/dev/null &")

    true
  end

  def self.run(path, options = {})
    @@kill     = 3600 # sec
    @@path     = path
    @@proc     = nil
    @@time     = nil
    @@options  = options
    @@success  = 0
    @@reflesh  = 10

    ENV['INPUTRC'] ||= '/etc/inputrc'

    ## locked
    unless lock
      puts 'already running'
      return 'already running'
    end

    ## start
    start = Time.now
    log "[#{start.strftime('%Y-%m-%d %H:%M:%S')}] script:#{@@path} ... start"

    ## dispatch
    app = ActionController::Integration::Session.new(Joruri::Application)
    app.get '/_script/sys/run/' + path.tr('#', '/').gsub(/^(.*?)\//, '\\1/script/')
    log 'success ' + @@proc.success.to_s + (@@proc.total ? "/#{@@proc.total}" : '')

    ## finish
    finish = Time.now
    past   = sprintf('%.2f', finish - start)
    log "[#{finish.strftime('%Y-%m-%d %H:%M:%S')}] script:#{@@path} ... finished (#{past} sec)"
    unlock

  rescue Exception => e
    error e
    error e.backtrace.slice(0, 20).join("\n")
    unlock
  end

  def self.total(num = 1)
    if num.is_a?(Fixnum)
      @@proc.total += num
    else
      @@proc.total = nil
    end
    if num != 1
      @@proc.updated_at = DateTime.now
      @@proc.save
    end
    @@proc.total
  end

  def self.current(num = 1)
    @@proc.current += num
    if (@@proc.current % @@reflesh) == 0
      value = @@proc.interrupted?
      raise InterruptException.new(value) if value == 'stop'
    end
    @@proc.save if @@proc.current >= @@proc.current_was + 100
    @@proc.current
  end

  def self.success(num = 1)
    @@proc.success += num
    if num > 0 && (@@proc.success % @@reflesh) == 0
      @@proc.updated_at = DateTime.now
      @@proc.save
    end
    @@proc.success
  end

  def self.error(message = nil)
    if message
      @@proc.error += 1
      log "Error: #{message}"
    end
    @@proc.error
  end

  def self.log(message)
    unless message.blank?
      @@proc.message = '' if @@proc.message.blank?
      @@proc.message += "#{message}\n"
      puts message
    end
    message
  end

  protected

  def self.lock
    @@proc = Sys::Process.lock(name: @@path, time_limit: @@kill)
    @@time = @@proc.created_at if @@proc
    @@proc
  end

  def self.keep_lock(attrs = {})
    return false if @@time != @@proc.created_at
    @@proc.updated_at = DateTime.now
    @@proc.attributes = attrs
    @@proc.save
  end

  def self.unlock
    @@proc.unlock if @@proc && @@proc.closed_at.nil?
  end

  class InterruptException < StandardError
    ## interrupt by admin
  end
end

## /usr/local/lib/ruby/gems/1.9.1/gems/rack-1.4.5/lib/rack/lock.rb
module Rack
  class LockXXX
    def call(env)
      is_http = caller.slice(-1, 1) !~ /script\/rails/

      old = env[FLAG]
      env[FLAG] = false
      @mutex.lock unless is_http
      response = @app.call(env)
      body = BodyProxy.new(response[2]) { @mutex.unlock unless is_http }
      response[2] = body
      response
    ensure
      @mutex.unlock unless body
      env[FLAG] = old
    end
  end
end
