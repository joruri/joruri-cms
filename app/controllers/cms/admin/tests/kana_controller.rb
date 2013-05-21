# encoding: utf-8
class Cms::Admin::Tests::KanaController < Cms::Controller::Admin::Base
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
  end
  
  def index
    @mode   = true
    @result = nil
    
    if params[:yomi_kana]
      @mode = 'ふりがな'
      @result = Cms::Lib::Navi::Kana.convert(params[:body].dup)
      
    elsif params[:talk_kana]
      @mode = '音声テキスト'
      @result = ERB::Util.html_escape(Cms::Lib::Navi::Jtalk.make_text(params[:body].dup))
      
    elsif params[:talk_file]
      @skip_layout = true
      talk = Cms::Lib::Navi::Jtalk.new
      talk.make params[:body]
      file = talk.output
      send_file file[:path], :type => file[:path], :filename => 'sound.mp3', :disposition => 'inline'
    end
  end
end
