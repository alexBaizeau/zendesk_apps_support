# frozen_string_literal: true

module ZendeskAppsSupport
  class Location
    extend ZendeskAppsSupport::Finders
    attr_reader :id, :name, :orderable, :collapsible, :product_code, :v2_only

    def self.unique_ids
      @ids ||= Set.new
    end

    def initialize(attrs)
      @id = attrs.fetch(:id)
      raise 'Duplicate id' if Location.unique_ids.include? @id
      Location.unique_ids.add @id
      @name = attrs.fetch(:name)
      @orderable = attrs.fetch(:orderable, false)
      @collapsible = attrs.fetch(:collapsible, false)
      @product_code = attrs.fetch(:product_code)
      @v2_only = attrs.fetch(:v2_only, product != Product::SUPPORT)
    end

    def product
      Product.find_by(code: product_code)
    end

    def self.all
      LOCATIONS_AVAILABLE
    end

    # the ids below match the enum values on the database, do not change them!
    LOCATIONS_AVAILABLE = [
      Location.new(id: 1, orderable: true, name: 'top_bar', product_code: Product::SUPPORT.code),
      Location.new(id: 2, orderable: true, name: 'nav_bar', product_code: Product::SUPPORT.code),
      Location.new(id: 3, orderable: true, collapsible: true, name: 'ticket_sidebar',
                   product_code: Product::SUPPORT.code),
      Location.new(id: 4, orderable: true, collapsible: true, name: 'new_ticket_sidebar',
                   product_code: Product::SUPPORT.code),
      Location.new(id: 5, orderable: true, collapsible: true, name: 'user_sidebar',
                   product_code: Product::SUPPORT.code),
      Location.new(id: 6, orderable: true, collapsible: true, name: 'organization_sidebar',
                   product_code: Product::SUPPORT.code),
      Location.new(id: 7, name: 'background', product_code: Product::SUPPORT.code),
      Location.new(id: 8, orderable: true, collapsible: true, name: 'chat_sidebar', product_code: Product::CHAT.code),
      Location.new(id: 9, name: 'modal', product_code: Product::SUPPORT.code, v2_only: true),
      Location.new(id: 10, name: 'ticket_editor', product_code: Product::SUPPORT.code, v2_only: true),
      Location.new(id: 11, name: 'nav_bar', product_code: Product::STANDALONE_CHAT.code, v2_only: false),
      Location.new(id: 12, name: 'system_top_bar', product_code: Product::SUPPORT.code),
      Location.new(id: 13, name: 'system_top_bar',
                   product_code: Product::STANDALONE_CHAT.code, v2_only: false),
      Location.new(id: 14, name: 'background',
                   product_code: Product::CHAT.code)
    ].freeze
  end
end
