# frozen_string_literal: true

require "test_helper"

# ADR-005: a page's props come from its <Controller><Action>Serializer through the type Typelizer
# generates, never from a hand-written interface.
class PageTypesTest < ActiveSupport::TestCase
  PAGES = Rails.root.join("app/javascript/pages")

  test "each page declares its serializer's type as its props, and only that" do
    Dir[PAGES.join("**/*.vue")].each do |file|
      *namespaces, controller, action = Pathname(file).relative_path_from(PAGES).sub_ext("").to_s.split("/")
      serializer = [ *namespaces.map(&:camelize), "#{controller}_#{action}_serializer".camelize ].join("::")
      source = File.read(file)

      if serializer.safe_constantize
        type = serializer.delete(":").delete_suffix("Serializer")
        assert_includes source, "defineProps<#{type}>()", "#{file} should declare defineProps<#{type}>()"
      else
        assert_no_match(/defineProps/, source, "#{file} has props but no #{serializer}")
      end
    end
  end
end
