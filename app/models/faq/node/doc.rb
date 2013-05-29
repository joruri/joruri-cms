# encoding: utf-8
class Faq::Node::Doc < Cms::Node
  #validate :validate_settings
  
  def setting_label(name)
    value = setting_value(name)
    case name
    when :show_concept_id
      return show_concept ? show_concept.name : nil
    when :show_layout_id
      return show_layout ? show_layout.title : nil
    end
    value
  end
  
  def show_concept
    @show_concept = Cms::Concept.find_by_id(setting_value(:show_concept_id))
  end
  
  def show_layout
    @show_layout = Cms::Layout.find_by_id(setting_value(:show_layout_id))
  end
  
  # def validate_settings
  # end
end