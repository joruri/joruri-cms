# encoding: utf-8
module Sys::Lib::EntityConversion
  
  def group_id_fields
    {
      Sys::Creator       => [ :group_id ],
      Sys::EditableGroup => [ :group_ids ],
      Sys::Group         => [ :parent_id ],
      Sys::UsersGroup    => [ :group_id ],
      Sys::UsersRole     => [ :group_id ],
    }
  end
  
  def text_fields
    {
      Sys::File     => [ :title ],
      Sys::RoleName => true,
    }
  end
  
end