require 'rubygems'
require 'i18n/active_record'
# Including this module into your model will allow you to add arbitrary
# attributes whose values are persisted in multiple languages in the database.
#
# For example, supposing you have an online shop, and you need to store the
# description of products in English and German. First, you should ensure that
# I18n.available_locales returns [:en, :de] (at least).
#
#     class Product
#       translatable_attribute_accessor :description
#     end
#     
#     product = Product.create                        => a new Product#123
#     product.description_en = "A thing"
#     product.description_de = "Ein Ding"
#
# The descriptions will be persisted in the translations table (or whatever
# your I18n::Backend::ActiveRecord is using - see that gem for more info),
# with the key 'product.descriptions.123'.
module TranslatableAttributes
  def self.included(mod)
    mod.send(:extend, ClassMethods)
    mod.send(:include, InstanceMethods)
    mod.send(:after_save, :save_translatable_attributes)
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
    def translatable_attribute_accessor(*attributes)
      attributes.each do |attr|
        I18n.available_locales.map(&:to_s).each do |locale|
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
end
