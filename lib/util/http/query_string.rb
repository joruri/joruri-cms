# encoding: utf-8
class Util::Http::QueryString
  def self.parse_query(query_string)
    query_string.to_s.split(/&/).each_with_object({}) do |setting, params|
      key, val = setting.split(/=/)
      params[key.to_sym] = val
    end
  end

  def self.build_query(params)
    query_string = params.inject('') do |_str, param|
      _str += '&' unless _str.empty?
      _str += "#{param[0]}=#{param[1]}"
    end
    query_string.blank? ? nil : query_string
  end

  def self.get_query(params = nil)
    build_query(get_query_params(params))
  end

  def self.get_query_params(params = nil)
    base_params = parse_query(Core.env['QUERY_STRING'])
    params = parse_query(params) if params.class == String
    params ||= {}
    base_params.merge(params)
  end
end
