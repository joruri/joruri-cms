SimpleCaptcha.setup do |sc|
  # default: 100x28
  sc.image_size = '100x28'

  # default: 5
  sc.length = 5

  # default: simply_blue
  # possible values:
  # 'embosed_silver',
  # 'simply_red',
  # 'simply_green',
  # 'simply_blue',
  # 'distorted_black',
  # 'all_black',
  # 'charcoal_grey',
  # 'almost_invisible'
  # 'random'
  sc.image_style = 'simply_blue'

  # default: low
  # possible values: 'low', 'medium', 'high', 'random'
  sc.distortion = 'medium'
end

module SimpleCaptcha
  module ModelHelpers
    module SingletonMethods
      def apply_simple_captcha(options = {})
        options = { :add_to_base => false }.merge(options)
        options[:valid_and_not_remove] = false unless options.include?(:valid_and_not_remove)
        
        class_attribute :simple_captcha_options
        self.simple_captcha_options = options

        unless self.is_a?(ClassMethods)
          include InstanceMethods
          extend ClassMethods

          attr_accessor :captcha, :captcha_key
        end
      end
    end

    module InstanceMethods
      def is_captcha_valid?
        return true if SimpleCaptcha.always_pass

        if captcha && captcha.upcase.delete(" ") == SimpleCaptcha::Utils::simple_captcha_value(captcha_key)
          SimpleCaptcha::Utils::simple_captcha_passed!(captcha_key) unless simple_captcha_options[:valid_and_not_remove]
          return true
        else
          message = simple_captcha_options[:message] || I18n.t(self.class.model_name.to_s.downcase, :scope => [:simple_captcha, :message], :default => :default)
          simple_captcha_options[:add_to_base] ? errors.add(:base, message) : errors.add(:captcha, message)
          return false
        end
      end
      
      def remove_captcha_key
        SimpleCaptcha::Utils::simple_captcha_passed!(captcha_key)
      end
    end
  end
  module ViewHelper
    def show_simple_captcha(options = {})
      SimpleCaptchaData.clear_old_data
      render :partial => SimpleCaptcha.partial_path, :locals => { :simple_captcha_options => simple_captcha_options(options) }
    end
  end
end
