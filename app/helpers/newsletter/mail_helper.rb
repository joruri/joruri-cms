# encoding: utf-8
module Newsletter::MailHelper

  ## wrap long string
  def text_wrap(text, col = 80, char = " ")
    text = text.gsub("\r\n", "\n")
    text.gsub(/(.{#{col}})(( *$\n?)| +)|(.{#{col}})/) do |match|
      if $3
        "#{$1}#{$2}"
      else
        "#{$1}#{$2}#{$4}#{char}"
      end
    end
  end

  def mail_text_wrap(text, col = 1, options = {})

    to_nbsp = lambda do |txt|
      txt.gsub(/(^|\t| ) +/) {|m| m.gsub(' ', '&nbsp;')}
    end

    text = "#{text}".force_encoding('utf-8')
    text = text.gsub(/\t/, "  ")
    text = text_wrap(text, col, "\t")
    text = h(text)
    text = to_nbsp.call(text)
    text = text.gsub(/\t/, '<wbr></wbr>')
    br(text)
  end

end