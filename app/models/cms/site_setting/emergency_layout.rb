# encoding: utf-8
class Cms::SiteSetting::EmergencyLayout < Cms::SiteSetting
  belongs_to :layout, foreign_key: :value, class_name: 'Cms::Layout'

  validates :value, presence: true, uniqueness: { scop: :name }

  scope :current_site, -> {
    where(site_id: Core.site.id)
  }
end
