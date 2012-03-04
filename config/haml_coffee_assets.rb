module HamlCoffeeAssets
  class Engine < Rails::Engine
    # add your valid haml-coffee options to this hash
    APP_CONFIG = {
      :preserve => "textarea,pre,code" # formerly 'config.hamlcoffee.preserve = ...'
    }
  end
end