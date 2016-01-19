# coding: UTF-8
module Edgarj  
  module PopupHelper
    # handle popup related fields to simplify params[] passing
    # from browser to server.
    #
    # === SEE ALSO
    # Edgarj.Popup.Field:: same logic at js side
    class PopupField
      attr_accessor(
          :id_target,
          :label_target,

          # NOTE: This is search-form specific hidden field
          # to store parent name.  This will be used when re-drawing
          # search-form.
          :label_hidden_field,
          :clear_link)

      # new from object_name and col_name
      def self.new_builder(object_name, col_name)
        new(object_name.to_s + '_' + col_name.to_s)
      end

      def initialize(id_target)
        raise Edgarj::NoPopupTarget if id_target.blank?

        @id_target    = id_target
        # Using id_target as suffix rather than prefix is to avoid
        # DOM-id conflict.  For example, if id_target is 'author_id' and
        # use it as prefix, then label_target would be something like
        # 'author_id_label_target' and it would be conflict with actual
        # author.id_label_target DB column.
        @label_target = '__edgarj_label_target_for_' + @id_target
        @label_hidden_field = '__edgarj_label_hidden_field_for_' + @id_target
        @clear_link   = @label_target + '_clear_link'
      end
    end
  end
end
