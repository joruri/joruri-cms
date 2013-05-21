# encoding: utf-8
module Newsletter::Model::Base::Letter

  def letter_types
    # [['PC版（テキスト形式）','pc_text'], ['PC版（HTML形式）','pc_html'], ['携帯版（テキスト形式）','mobile_text'], ['携帯版（HTML形式）','mobile_html']]
    [['PC版（テキスト形式）','pc_text'], ['携帯版（テキスト形式）','mobile_text']]
  end

  def letter_type_name
    letter_types.each do |name, id|
      return name if letter_type.to_s == id
    end
    nil
  end

  def text?
    return true unless self.letter_type
    self.letter_type =~ /text/i
  end

  def mobile?
    return false unless self.letter_type
    self.letter_type =~ /mobile/i
  end

end