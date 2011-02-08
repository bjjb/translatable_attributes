$: << File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'test/unit'
require 'translatable_attributes'

# Prepare database
ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => ':memory:'
)
# Create Translations table
ActiveRecord::Base.connection.create_table :translations, :force => true do |t|
  t.string :locale
  t.string :key
  t.string :value
  t.text :interpolations
  t.boolean :is_proc
  t.references :translatable, :polymorphic => true
end
# Set the I18n backend
I18n.backend = I18n::Backend::ActiveRecord.new
# Create Models table
ActiveRecord::Base.connection.create_table :models, :force => true do |t|
  t.string :name
end

class TranslatableAttributesTest < Test::Unit::TestCase
# Create the test model
  class Model < ActiveRecord::Base
    include TranslatableAttributes
  end

  def setup
    I18n.translate("English", :locale => :en)
    @model = Model.create!
  end

  def test_gets_locales_from_i18n
    assert_equal I18n.available_locales, TranslatableAttributes.available_locales
    assert_equal I18n.available_locales.map(&:to_s), TranslatableAttributes.locales
    I18n.available_locales = %W(xx yy-ZZ)
    assert_equal [:xx, :"yy-ZZ"], I18n.available_locales
    assert_equal [:xx, :"yy-ZZ"], TranslatableAttributes.available_locales
    assert_equal %W(xx yy-ZZ), TranslatableAttributes.locales
    assert_equal %W(xx yy_ZZ), TranslatableAttributes.locale_suffices
  end

  def test_setup
    assert_nothing_raised "something's wrong with ActiveRecord?" do
      model = Model.create!(:name => "Heidi Klum")
      assert_equal "Heidi Klum", model.name
    end
    assert_nothing_raised do
      Model.send(:translatable_attribute_accessor, :foo)
      I18n::Backend::ActiveRecord::Translation.create!(:locale => :en, :key => 'foo', :value => 'bar')
      assert_equal "bar", I18n.t("foo", :locale => :en), "something's wrong with I18n::Backend"
    end
  end

  def test_sanity
    
  end

  def test_works_for_existing_locales
    I18n.available_locales = :en
    Model.send(:translatable_attribute_accessor, :x)
    model = Model.new
    assert_respond_to model, :x
    assert_respond_to model, :x=
    assert_respond_to model, :x_en
    assert_respond_to model, :x_en=
    assert_respond_to model, :x_en?
    assert_respond_to model, :x_before_type_cast
  end

if false
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

  def test_existing_records_are_not_needed
    I18n::Backend::ActiveRecord::Translation.delete_all
    m = Model.create(:foo_en => "Boo", :foo_de => "Bü", :foo_it => "Bú")
    assert_equal "Boo", m.foo_en
    assert_equal "Bü", m.foo_en
    assert_equal "Bú", m.foo_en
  end
end
end
