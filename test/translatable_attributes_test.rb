$: << File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'test/unit'
require 'translatable_attributes'

class TranslatableAttributesTest < Test::Unit::TestCase
  class Model < ActiveRecord::Base; end

  def setup
    ActiveRecord::Base.establish_connection(
      :adapter => 'sqlite3',
      :database => ':memory:'
    )

    ActiveRecord::Base.connection.create_table :models, :force => true do |t|
      t.string :name
    end

    ActiveRecord::Base.connection.create_table :translations, :force => true do |t|
      t.string :locale
      t.string :key
      t.string :value
      t.text :interpolations
      t.boolean :is_proc
    end

    I18n.backend = I18n::Backend::ActiveRecord.new
    I18n.available_locales = %W(en de-DE)

    Model.send(:include, TranslatableAttributes)
    Model.send(:translatable_attribute_accessor, :foo)

    @model = Model.create!
  end

  def test_setup
    assert_nothing_raised do
      model = Model.create!(:name => "Heidi Klum")
      assert_equal "Heidi Klum", model.name
    end
    assert_nothing_raised do
      I18n::Backend::ActiveRecord::Translation.create!(:locale => 'en', :key => 'foo', :value => 'bar')
      assert_equal "bar", I18n.t("foo")
    end
  end

  def test_creation_of_methods
    assert @model.respond_to?('foo_en')
    assert @model.respond_to?('foo_en=')
    assert @model.respond_to?('foo_de_de')
    assert @model.respond_to?('foo_de_de=')
  end

  def test_accessors
    @model.foo_en = "Boo"
    assert_equal "Boo", @model.foo_en
    @model.foo_de_de = "Bü"
    assert_equal "Bü", @model.foo_de_de
  end

  def test_after_save
    count = I18n::Backend::ActiveRecord::Translation.count

    @model.foo_en = "Hello"
    @model.foo_de_de = "Hello"
    @model.save
    assert_equal count += 2, I18n::Backend::ActiveRecord::Translation.count

    Model.create(:foo_en => "Boo")
    assert_equal count += 1, I18n::Backend::ActiveRecord::Translation.count

    Model.create(:foo_en => "Bar", :foo_de_de => "Yo")
    assert_equal count += 2, I18n::Backend::ActiveRecord::Translation.count
  end

  def test_key_and_locale_method
    key = @model.translatable_attribute_record_key("x_y")
    assert_equal "models.#{@model.id}.x_y", key
  end
end
