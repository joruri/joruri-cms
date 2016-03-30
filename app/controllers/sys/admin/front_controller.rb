# encoding: utf-8
class Sys::Admin::FrontController < Cms::Controller::Admin::Base
  def index
    @messages = Sys::Message.where(state: 'public')
                            .order(published_at: :desc)

    @maintenances = Sys::Maintenance.where(state: 'public')
                                    .order(published_at: :desc)
  end
end
