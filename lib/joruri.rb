# encoding: utf-8
module Joruri

  def self.version
    "2.2.1"
  end

  def self.config
    if !defined?($joruri_config)
      $joruri_config = {}
      YAML.load_file("#{Rails.root}/config/application.yml").each do |mod, v|
        v.each {|key, val| $joruri_config["#{mod}_#{key}".to_sym] = val.blank? ? nil : val }
      end
    end
    $joruri_config
  end

  def self.admin_uri
    Joruri.config[:sys_admin_uri]
  end

end
