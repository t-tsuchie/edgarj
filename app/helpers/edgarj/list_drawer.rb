# coding: UTF-8

module Edgarj
  # ListDrawer will be obsoleted.  Column will be handled by
  # Edgarj::Drawer::ColumnInfo
  module ListDrawer
    # Base for popup-list and normal-list column drawer
    #
    # Sub class of Drawer to draw list
    class Base
      include ERB::Util

      # * drawer        - Edgarj::Drawer::Base object
      # * options
      def initialize(drawer, options = {})
        @drawer = drawer
      end

      def draw_column_header(col, options={})
        @drawer.vc.content_tag(:th) do
          col.column_header_label(@drawer.vc, @drawer.page_info, options)
        end
      end

      def draw_column(rec, col)
        @drawer.vc.content_tag(:td, td_options(rec, col)) do
          col.column_value(rec, @drawer)
        end
      end

      private

      # <td> options
      def td_options(rec, col)
        col.tag_options
      end
    end

    # Drawer for record list in Edgarj CRUD view.
    #
    class Normal < Base
      def initialize(edgarj_drawer, options = {})
        super(edgarj_drawer, options)
      end

      # <td> options
      #
      # merge css to let Edgarj.click_listCB() work with base result.
      # When the column is parent, do nothing.
      def td_options(rec, col)
        super.merge(class: '_edgarj_list_column'){|key, _old, _new| [_old, _new].flatten}
      end
    end
  end
end
