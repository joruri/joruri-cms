# encoding: utf-8
module Newsletter::MailHelper
  ## wrap long string
  def text_wrap(text, col = 80, char = ' ')
    text = text.gsub("\r\n", "\n")
    text.gsub(/(.{#{col}})(( *$\n?)| +)|(.{#{col}})/) do |_match|
      if Regexp.last_match(3)
        "#{Regexp.last_match(1)}#{Regexp.last_match(2)}"
      else
        "#{Regexp.last_match(1)}#{Regexp.last_match(2)}#{Regexp.last_match(4)}#{char}"
      end
    end
  end

  def mail_text_wrap(text, col = 1, _options = {})
    to_nbsp = lambda do |txt|
      txt.gsub(/(^|\t| ) +/) { |m| m.gsub(' ', '&nbsp;') }
    end

    text = text.to_s.force_encoding('utf-8')
    text = text.gsub(/\t/, '  ')
    text = text_wrap(text, col, "\t")
    text = h(text)
    text = to_nbsp.call(text)
    text = text.gsub(/\t/, '<wbr></wbr>')
    br(text)
  end
end
