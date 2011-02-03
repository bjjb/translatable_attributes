Translatable Attributes
=======================

Works with I18n to allow you to magically translate an attribute of an object.

Including this module into your model will allow you to add arbitrary
attributes whose values are persisted in multiple languages in the database.

For example, supposing you have an online shop, and you need to store the
description of products in English and German. First, you should ensure that
`I18n.available_locales` returns  `[:en, :de]` (at least), for this example.
Then you can do this:

    class Product
      include TranslatableAttributes
      translatable_attribute_accessor :description
    end
    
    product = Product.create(
      :description_en => "English",
      :description_de => "Kein Englisch!"
    )

The descriptions will be persisted in the translations table (or whatever
your I18n::Backend::ActiveRecord is using - see that gem for more info),
with the key 'products.123.description'.

Installation
------------

    gem install translatable_attributes

or in a Rails projects, add this to your Gemfile

    gem 'translatable_attributes'

It pulls in its dependencies itself.

Caveats
-------

This is a first version, so it may have bugs, and could certainly be improved.
Please feel free to do so!

Authors
-------

JJ Buckley <jj@bjjb.org>

Copyright
---------

Released under a [GPL][copy] - no responsibility, etc.

[copy]: [https://github.com/jjbuckley/translatable_attributes/raw/master/COPYING]
