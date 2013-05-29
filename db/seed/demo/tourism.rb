# encoding: utf-8

def truncate_table(table)
  puts "TRUNCATE TABLE #{table}"
  ActiveRecord::Base.connection.execute "TRUNCATE TABLE #{table}"
end

truncate_table(Tourism::Genre.table_name)
truncate_table(Tourism::Spot.table_name)

Core.user       = Sys::User.find_by_account('admin')
Core.user_group = Core.user.groups[0]

p1 = p2 = p3 = nil
File.new("#{Rails.root}/db/seed/demo/tourism/genres.txt").read.force_encoding("utf-8").split(/\r\n|\n/).each_with_index do |line, idx|
  next if line.strip.blank?
  data = line.split(/\t/)
  if !data[0].to_s.strip.blank?
    p1 = ::Tourism::Genre.new
    p1.attributes = {
      :concept_id => 1,
      :parent_id  => 0,
      :level_no   => 1,
      :sort_no    => idx,
      :state      => 'public',
      :layout_id  => 6,
      :content_id => 8,
      :name       => "genre1_#{idx}",
      :title      => data[0]
    }
    p1.save(:validate => false)
  end
  if !data[1].to_s.strip.blank?
    p2 = Tourism::Genre.new
    p2.attributes = {
      :concept_id => 1,
      :parent_id  => p1.id,
      :level_no   => 2,
      :sort_no    => idx,
      :state      => 'public',
      :layout_id  => 6,
      :content_id => 8,
      :name       => "genre2_#{idx}",
      :title      => data[1]
    }
    p2.save(:validate => false)
  end
  if !data[2].to_s.strip.blank?
    p3 = Tourism::Genre.new
    p3.attributes = {
      :concept_id => 1,
      :parent_id  => p2.id,
      :level_no   => 3,
      :sort_no    => idx,
      :state      => 'public',
      :layout_id  => 6,
      :content_id => 8,
      :name       => "genre3_#{idx}",
      :title      => data[2]
    }
    p3.save(:validate => false)
  end
end

p1 = p2 = p3 = nil
File.new("#{Rails.root}/db/seed/demo/tourism/spots.txt").read.force_encoding("utf-8").split(/\r\n|\n/).each_with_index do |line, idx|
  next if line.strip.blank?
  data = line.split(/\t/)
  
  genre = Tourism::Genre.find_by_title(data[1])
  next unless genre
  
  spot = Tourism::Spot.new
  spot.attributes = {
    :state       => 'public',
    :content_id  => 8,
    :name        => nil,
    :title       => data[4],
    :title_kana  => data[5],
    :body        => "<p>#{data[14]}</p>",
    :guide_body  => data[7],
    :language_id => 1,
    :genre_ids   => "#{genre.id}",
  }
  spot.save(:validate => false)
  #exit
end
