# encoding: utf-8
module Cms::Model::Rel::Inquiry
  
  @@inquiry_presence_of = [:group_id, :tel, :email]
  
  def self.included(mod)
    mod.belongs_to :inquiry, :foreign_key => 'unid', :class_name => 'Cms::Inquiry',
      :dependent => :destroy

    mod.after_save :save_inquiry
  end

  def in_inquiry
    unless val = @in_inquiry
      val = {}
      val = inquiry.attributes if inquiry
      @in_inquiry = val
    end
    @in_inquiry
  end

  def in_inquiry=(values)
    @inquiry = {}
    values.each {|k,v| @inquiry[k.to_s] = v if !v.blank? }
    @in_inquiry = @inquiry
  end

  def inquiry_states
   {'visible' => '表示', 'hidden' => '非表示'}
  end
  
  def default_inquiry(params = {})
    unless g = Core.user.group
      return params
    end
    {:state => 'visible', :group_id => g.id, :tel => g.tel, :email => g.email}.merge(params)
  end

  def unset_inquiry_email_presence
    @@inquiry_presence_of.delete(:email)
  end
  
  def inquiry_presence?(name)
    @@inquiry_presence_of.index(name) != nil
  end
  
  def validate_inquiry
    if @inquiry && @inquiry['state'] == 'visible'
      if inquiry_presence?(:group_id) && @inquiry['group_id'].blank?
        errors[:in_inquiry_group_id] = error_locale(:empty)
      end
      if inquiry_presence?(:tel) && @inquiry['tel'].blank?
        errors[:in_inquiry_tel] = error_locale(:empty)
      end
      errors[:in_inquiry_tel] = error_locale(:onebyte_characters) if @inquiry['tel'].to_s !~/^[ -~｡-ﾟ]*$/
      errors[:in_inquiry_fax] = error_locale(:onebyte_characters) if @inquiry['fax'].to_s !~/^[ -~｡-ﾟ]*$/
      
      if inquiry_email_setting != "hidden"
        if inquiry_presence?(:email) && @inquiry['email'].blank?
          errors[:in_inquiry_email] = error_locale(:blank)
        end
        errors[:in_inquiry_email] = error_locale(:invalid) if @inquiry['email'].to_s !~/^[ -~｡-ﾟ]*$/
      end
    end
  end

  def save_inquiry
    return false unless unid
    return true unless @inquiry
    return true unless @inquiry.is_a?(Hash)
    
    values = @inquiry
    @inquiry = nil
    
    _inq = inquiry  || Cms::Inquiry.new
    _inq.created_at ||= Core.now
    _inq.updated_at   = Core.now
    _inq.state        = values['state']
    _inq.group_id     = values['group_id']
    _inq.charge       = values['charge']
    _inq.tel          = values['tel']
    _inq.fax          = values['fax']
    if inquiry_email_setting != "hidden"
      _inq.email      = values['email']
    end

    if _inq.new_record?
      _inq.id = unid
      return false unless _inq.save_with_direct_sql
    else
      return false unless _inq.save
    end
    inquiry(true)
    return true
  end
  
  def inquiry_email_setting
    "visible"
  end
end
