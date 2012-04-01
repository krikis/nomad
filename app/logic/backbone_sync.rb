module BackboneSync
  module Rails
    module Faye
      mattr_accessor :root_address
      self.root_address = 'http://localhost:9292'

      module Observer
        puts "TESTEN\n\n\n"
        def after_update(model)
          Event.new(model, :update).publish
        end

        def after_create(model)
          puts "#{model.inspect} created"
          Event.new(model, :create).publish
        end

        def after_destroy(model)
          Event.new(model, :destroy).publish
        end
      end

      class Event
        def initialize(model, event)
          @model = model
          @event = event
        end

        def broadcast
          Net::HTTP.post_form(uri, :message => message)
        end

        private

        def uri
          URI.parse("#{BackboneSync::Rails::Faye.root_address}/faye")
        end

        def message
          { :channel => channel,
            :data => data          }.to_json
        end

        def channel
          "/sync/#{@model.class.table_name}"
        end

        def data
          { @event => { @model.id => @model.as_json } }
        end
      end
    end
  end
end