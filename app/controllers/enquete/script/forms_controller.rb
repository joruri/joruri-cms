# encoding: utf-8
class Enquete::Script::FormsController < Cms::Controller::Script::Publication
  def publish
    render :text => "OK"
  end
end
