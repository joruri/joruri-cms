# encoding: utf-8
class Faq::Piece::RecentDoc < Cms::Piece
  validate :validate_settings

  def validate_settings
    return if in_settings['list_count'].blank?

    if in_settings['list_count'] !~ /^[0-9]+$/
      errors.add(:base,"#{self.class.human_attribute_name :list_count} #{errors.generate_message(:base, :not_a_number)}")
    end
  end
end
