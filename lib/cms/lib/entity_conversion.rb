# encoding: utf-8
module Cms::Lib::EntityConversion
  
  def group_id_fields
    {
      Cms::Inquiry => [:group_id],
    }
  end
  
  def text_fields
    {
      Cms::Concept        => true,
      Cms::ContentSetting => [:value],
      Cms::Content        => true,
      Cms::DataFileNode   => true,
      Cms::DataFile       => true,
      Cms::DataText       => true,
      Cms::EmbeddedFile   => true,
      Cms::Inquiry        => true,
      Cms::KanaDictionary => [:body],
      Cms::Layout         => true,
      Cms::MapMarker      => [:name],
      Cms::Map            => [:title],
      Cms::NodeSetting    => [:value],
      Cms::Node           => true,
      Cms::PieceLinkItem  => true,
      Cms::PieceSetting   => [:value],
      Cms::Piece          => true,
      Cms::SiteSetting    => [:value],
    }
  end
end