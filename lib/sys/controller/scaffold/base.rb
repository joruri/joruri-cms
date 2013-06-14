# encoding: utf-8
module Sys::Controller::Scaffold::Base
  def edit
    show
  end
  
protected
  def _index(items, options = {})
    respond_to do |format|
      format.html { render options[:render] }
      format.xml  { render :xml => items.to_xml(:dasherize => false, :root => 'items') }
    end
  end
  
  def _show(item, options = {})
    return send(params[:do], item) if params[:do]
    respond_to do |format|
      format.html { render options[:render] }
      format.xml  { render :xml => item.to_xml(:dasherize => false, :root => 'item') }
    end
  end
  
  def _create(item, options = {}, &block)
    if item.creatable? && item.save
      status         = params[:_created_status] || :created
      location       = options[:location] || url_for(:action => :index)
      flash[:notice] = options[:notice] || '登録処理が完了しました。'
      Sys::OperationLog.log(request, :item => item)
      yield if block_given?
      
      respond_to do |format|
        format.html { redirect_to(location) }
        format.xml  { render(:xml => item.to_xml(:dasherize => false), :status => status, :location => location) }
      end
    else
      flash.now[:notice] = '登録処理に失敗しました。'
      respond_to do |format|
        format.html { render (options[:render] || :new) }
        format.xml  { render(:xml => item.errors, :status => :unprocessable_entity) }
      end
    end
  end
  
  def _update(item, options = {}, &block)
    if item.editable? && item.save
      location       = options[:location] || url_for(:action => :index)
      flash[:notice] = '更新処理が完了しました。'
      Sys::OperationLog.log(request, :item => item)
      yield if block_given?
      
      respond_to do |format|
        format.html { redirect_to(location) }
        format.xml  { head :ok }
      end
    else
      flash.now[:notice] = '更新処理に失敗しました。'
      respond_to do |format|
        format.html { render (options[:render] || :edit) }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def _destroy(item, options = {}, &block)
    if item.deletable? && item.destroy
      location       = options[:location] || url_for(:action => :index)
      flash[:notice] = options[:notice] || '削除処理が完了しました。'
      Sys::OperationLog.log(request, :item => item)
      yield if block_given?
      
      respond_to do |format|
        format.html { redirect_to(location) }
        format.xml  { head :ok }
      end
    else
      flash.now[:notice] = '削除処理に失敗しました。'
      respond_to do |format|
        format.html { render (options[:render] || :show) }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end
end