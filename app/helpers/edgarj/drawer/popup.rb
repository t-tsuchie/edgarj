module Edgarj
  module Drawer
    # PopupDrawer is the same as Drawer to draw 'belongs_to' model
    # to popup window.
    #
    # For example, AuthorPopupDrawer is to draw Author popup,
    # which is called from Book page.
    #
    # * options
    #   * list_drawer_options   - options for Edgarj::ListDrawer::Normal
    class Popup < Base
      def draw_row(record, &block)
        @vc.content_tag(:tr,
            class:  "list_line#{@line_color} edgarj_row edgarj_popup_list_row",
            data:   {id: record.id, name: record.name}) do
          yield
        end
      end

      def draw_list(list)
        @line_color = 1
        d           = Edgarj::ListDrawer::Normal.new(
            self,
            @options[:list_drawer_options] || {})

        @vc.content_tag(:table, width: '100%', class: 'list') do
          @vc.content_tag(:tr) do
            for col in columns_for(list_columns, :list) do
              @vc.concat d.draw_column_header(col, id_target: @params[:id_target])
            end
          end +
          @vc.capture do
            for rec in list do
              @line_color = 1 - @line_color
              @vc.concat(draw_row(rec) do
                for col in columns_for(list_columns, :list) do
                  @vc.concat d.draw_column(rec, col)
                end
              end)
            end
          end
        end
      end
    end
  end
end
