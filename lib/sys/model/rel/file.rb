# encoding: utf-8
module Sys::Model::Rel::File
  extend ActiveSupport::Concern

  included do
    has_many :files, foreign_key: 'parent_unid', class_name: 'Sys::File',
                     primary_key: 'unid', dependent: :destroy

    after_destroy :close_files
  end

  ## Remove the temporary flag.
  def fix_tmp_files(tmp_id)
    Sys::File.fix_tmp_files(tmp_id, unid)
    true
  end

  def public_files_path
    "#{::File.dirname(public_path)}/files"
  end

  def publish_files
    # return true unless @save_mode == :publish
    return true if files.empty?

    public_dir = public_files_path
    file_paths = []

    files.each do |file|
      upload_path = file.upload_path
      upload_dir  = ::File.dirname(upload_path)

      paths = {
        upload_path               => "#{public_dir}/#{file.name}",
        "#{upload_dir}/thumb.dat" => "#{public_dir}/thumb/#{file.name}"
      }
      file_paths << "#{public_dir}/#{file.name}"
      file_paths << "#{public_dir}/thumb/#{file.name}"

      paths.each do |fr, to|
        next unless ::Storage.exists?(fr)
        next if ::Storage.exists?(to) && (::Storage.mtime(to) >= ::Storage.mtime(fr))
        ::Storage.mkdir_p(::File.dirname(to)) unless ::Storage.exists?(::File.dirname(to))
        ::Storage.cp(fr, to)
      end
    end

    ## remove old files
    dir_files = []
    ::Storage.entries(public_dir).each {|n| dir_files << "#{public_dir}/#{n}" }
    if ::Storage.exists?("#{public_dir}/thumb")
      ::Storage.entries("#{public_dir}/thumb").each {|n| dir_files << "#{public_dir}/thumb/#{n}" }
    end
    dir_files.each do |file|
      next if ::Storage.directory?(file)
      next if file_paths.index(file)
      ::Storage.rm_rf(file)
    end

    true
  end

  def close_files
    # return true unless @save_mode == :close

    dir = public_files_path
    ::Storage.rm_rf(dir) if ::Storage.exists?(dir)
    true
  end
end
