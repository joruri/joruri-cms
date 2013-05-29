# encoding: utf-8
class Tourism::Content::Spot < Cms::Content
  def rewrite_configs
    conf = []
    if node = spot_node
      line  = "RewriteRule ^#{node.public_uri}" + '((\d{4})(\d\d)(\d\d)(\d\d)(\d\d)(\d).*)'
      line += " #{public_path.gsub(/.*(\/_contents\/)/, '\\1')}/spots/$2/$3/$4/$5/$6/$1 [L]"
      conf << line
    end
    if node = photo_node
      line  = "RewriteRule ^#{node.public_uri}" + '((\d{4})(\d\d)(\d\d)(\d\d)(\d\d)(\d).*)'
      line += " #{public_path.gsub(/.*(\/_contents\/)/, '\\1')}/photos/$2/$3/$4/$5/$6/$1 [L]"
      conf << line
    end
    if node = movie_node
      line  = "RewriteRule ^#{node.public_uri}" + '((\d{4})(\d\d)(\d\d)(\d\d)(\d\d)(\d).*)'
      line += " #{public_path.gsub(/.*(\/_contents\/)/, '\\1')}/movies/$2/$3/$4/$5/$6/$1 [L]"
      conf << line
    end
    conf
  end
  
  def genre_node
    return @genre_node if @genre_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'Tourism::Genre'
    @genre_node = item.find(:first, :order => :id)
  end
  
  def area_node
    return @area_node if @area_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'Tourism::Area'
    @area_node = item.find(:first, :order => :id)
  end
  
  def spot_node
    return @spot_node if @spot_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'Tourism::Spot'
    @spot_node = item.find(:first, :order => :id)
  end
  
  def search_spot_node
    return @search_spot_node if @search_spot_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'Tourism::SearchSpot'
    @search_spot_node = item.find(:first, :order => :id)
  end
  
  def photo_node
    return @photo_node if @photo_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'Tourism::Photo'
    @photo_node = item.find(:first, :order => :id)
  end
  
  def search_photo_node
    return @search_photo_node if @search_photo_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'Tourism::SearchPhoto'
    @search_photo_node = item.find(:first, :order => :id)
  end
  
  def movie_node
    return @movie_node if @movie_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'Tourism::Movie'
    @movie_node = item.find(:first, :order => :id)
  end
  
  def search_movie_node
    return @search_movie_node if @search_movie_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'Tourism::SearchMovie'
    @search_movie_node = item.find(:first, :order => :id)
  end
  
  def mouth_node
    return @mouth_node if @mouth_node
    item = Cms::Node.new.public
    item.and :content_id, id
    item.and :model, 'Tourism::Mouth'
    @mouth_node = item.find(:first, :order => :id)
  end
end