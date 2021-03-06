# encoding: utf-8
class Util::Sequencer
  def self.next_id(name, options = {})
    name    = name.to_s
    version = options[:version] || 0

    lock = Util::File::Lock.lock("#{name}_#{version}")
    raise('error: sequencer locked') unless lock

    seq = Sys::Sequence.versioned(version.to_s).find_by(name: name)

    if seq
      seq.value += 1
    else
      seq = Sys::Sequence.new
      seq.name = name
      seq.version = version
      seq.value = 1
    end
    seq.save

    lock.unlock

    if options[:md5]
      require 'digest/md5'
      return Digest::MD5.new.update(seq.value.to_s)
    end
    seq.value
  end
end
