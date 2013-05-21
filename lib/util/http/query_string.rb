# encoding: utf-8
class Util::Http::QueryString
  
  def self.parse_query(query_string)
    query_string.to_s.split(/&/).inject({}) do |params, setting|
      key, val = setting.split(/=/) 
      params[key.to_sym] = val
      params
    end
  end
  
  def self.build_query(params)
    query_string = params.inject("") do |str, param|
      str += "&" if str.size > 0
      str += "#{param[0]}=#{param[1]}"
    end
    query_string.blank? ? nil : query_string
  end
  
  def self.get_query(params = nil)
    build_query(get_query_params(params))
  end
  
  def self.get_query_params(params = nil)
    base_params = parse_query(Core.env["QUERY_STRING"])
    if params.class == String
      params = parse_query(params)
    end
    params ||= {}
    base_params.merge(params)
  end
  
end