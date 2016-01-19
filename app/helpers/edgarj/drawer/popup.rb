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
      def draw_list(list)
        line_color  = 1
        d           = Edgarj::ListDrawer::Normal.new(
            self,
            @options[:list_drawer_options] || {})

        @vc.content_tag(:table, width: '100%', class: 'list') do
          @vc.content_tag(:tr) do
            ''.html_safe.tap do |result|
              for col in columns_for(list_columns) do
                result << d.draw_column_header(col, id_target: @params[:id_target])
              end
            end
          end +
          ''.html_safe.tap do |trs|
            for rec in list do
              line_color = 1 - line_color
              d.set_path(rec)
              trs << @vc.content_tag(:tr,
                        class:  "list_line#{line_color} edgarj_popup_list_row",
                        data:   {id: rec.id, name: rec.name}) do
                ''.html_safe.tap do |cols|
                  for col in columns_for(list_columns) do
                    cols << d.draw_column(rec, col)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
