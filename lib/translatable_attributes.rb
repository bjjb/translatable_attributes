require 'rubygems'
require 'i18n/active_record'
# Including this module into your model will allow you to add arbitrary
# attributes whose values are persisted in multiple languages in the database.
#
# For example, supposing you have an online shop, and you need to store the
# description of products in English (en) and Swiss-German (de_ch)
#
#     class Product
#       include TranslatableAttributes
#       translatable_attribute_accessor :description
#     end
#     
#     product = Product.create                        => a new Product#123
#     product.description_en = "A thing"
#     product.description_de_ch = "Ein Ding"
#
# The descriptions will be persisted in the translations table (or whatever
# your I18n::Backend::ActiveRecord is using - see that gem for more info).
module TranslatableAttributes

  def self.included(mod)
    mod.send(:extend, ClassMethods)
    mod.send(:include, InstanceMethods)
  end

  module ClassMethods
    # Adds a reader and writer for each available locale for each of the given
    # attributes. For example (and assuming that the available locales are :en
    # and :de):
    #
    #     I18n.available_locales                            # => [:en, :de]
    #
    #     class Post < ActiveModel::Base
    #       translatable_attribute_accessor :title, :body
    #     end
    #
    # This creates the methods `title_en`, `title_en=`, `title_de`,
    # `title_de=`, `body_en`, `body_en=`, `body_de` and `body_de=`
    # 
    # You can see the available translations for each attribute with
    # `translated_titles`, and `translated_bodies`.
    # 
    # Like regular `attr_accessor` methods, you can call them separately:
    #
    #     class Post < ActiveModel::Base
    #       translatable_attribute_accessor :title
    #       translatable_attribute_accessor :body, :locales => [:all, :it]
    #     end
    #
    # In the previous example, all Posts will additionally have a
    # "translation" for the body in Italian (which is null, initially), even
    # if `I18n.available_locales` doesn't include that locale.
    #
    # Regular attribute methods all apply, such as `body_en?` and
    # `body_en_before_type_cast` (see ActiveModel::AttributeMethods).
    def translatable_attribute_accessor(*attributes)
      attributes.each do |attr|
        I18n::Backend::ActiveRecord::Translation.available_locales.map(&:to_s).each do |locale|
          class_eval do
            name = "#{attr.to_s}_#{locale.gsub('-', '_').downcase}"

            define_method name do
              translatable_attribute_record(attr, locale).value
            end

            define_method "#{name}=" do |value|
              translatable_attribute_record(attr, locale).value = value
            end

          end
        end
      end
    end
  end

  module InstanceMethods
    def save_translatable_attributes
      @translatable_attribute_records.each do |locale, records|
        records.each do |attr, record|
          record.key = translatable_attribute_record_key(attr)
          record.save!
        end
      end unless @translatable_attribute_records.nil?
    end

    def translatable_attribute_record_key(attr)
      "#{self.class.name.demodulize.tableize}.#{to_param}.#{attr}"
    end

    def translatable_attribute_record(attr, locale)
      key = translatable_attribute_record_key(attr)
      @translatable_attribute_records ||= {}
      @translatable_attribute_records[locale] ||= {}
      @translatable_attribute_records[locale][attr] ||= I18n::Backend::ActiveRecord::Translation.locale(locale).find_by_key(key)
      @translatable_attribute_records[locale][attr] ||= I18n::Backend::ActiveRecord::Translation.locale(locale).build
    end
  end

  class << self
    def available_locales
      I18n.available_locales
    end

    def locales
      available_locales.map(&:to_s)
    end

    def locale_suffices
      locales.map { |l| l.gsub('-', '_') }
    end
  end
end
