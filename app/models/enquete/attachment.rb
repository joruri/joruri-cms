class Enquete::Attachment < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Sys::Model::Auth::Free
  include Sys::Model::Base::File
  include Sys::Model::Rel::Unid

  belongs_to :site, class_name: 'Cms::Site'
  belongs_to :answer_column

end
