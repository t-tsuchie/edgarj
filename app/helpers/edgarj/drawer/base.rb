module Edgarj
  module Drawer
    # 'Mediator' to draw list and form of the model on the view.
    #
    # This collaborate with the following sub classes:
    # Edgarj::ListDrawer::Normal::    for list
    # Edgarj::FormDrawer::Base::      for data entry form
    # Edgarj::FormDrawer::Search::    for search form
    class Base
      attr_accessor :vc, :params, :model, :page_info

      # * options
      #   * list_drawer_options   - options for Edgarj::ListDrawer::Normal
      #   * draw_form_options     - options for draw_form_options
      def initialize(view_context, params, page_info, model, options={})
        @vc         = view_context
        @params     = params
        @page_info  = page_info
        @model      = model
        @options    = options.dup
      end

  # level-1 methods which may be modified most frequently:

      # define model-wide default columns for view.
      #
      # If you need to customize, overwrite it at derived model class.
      # Example:
      #   def columns
      #     %w(id name email updated_at)
      #   end
      #
      # === SEE ALSO
      # list_columns::         define list columns
      # form_columns::         define form columns
      # search_form_columns::  define search form columns
      def columns
        @model.columns.map{|c| c.name}
      end

      # This defines list columns.
      # You can overwrite this method at each model if it is different from
      # columns.  Default is calling columns().
      #
      # === SEE ALSO
      # columns::              define default columns
      # form_columns::         define form columns
      # search_form_columns::  define search form columns
      #
      def list_columns
        columns
      end

      # This defines form columns.
      # You can overwrite this method at each model if it is different from
      # columns.  Default is calling columns().
      #
      # === SEE ALSO
      # columns::              define default columns
      # list_columns::         define list columns
      # search_form_columns::  define search form columns
      #
      def form_columns
        columns
      end

      # This defines search-form columns.
      # You can overwrite this method at each model if it is different from
      # columns.  Default is calling columns().
      #
      # === SEE ALSO
      # columns::              define default columns
      # list_columns::         define list columns
      # form_columns::         define form columns
      #
      def search_form_columns
        columns
      end

  # level-2 methods which may be modified occasionally:

      # This defines popup path for the column on the model.
      #
      # Default returns parent model's popup-controller.
      # For example, book.author_id -> 'authors_popup' path
      #
      # You can overwrite this method at each model if it is different from
      # columns.
      #
      # @see popup_path_on_search     popup path for the column on the model's search form
      def popup_path(col)
        parent_model = @model.belongs_to_AR(col)
        raise 'Parent is nil' if !parent_model

        popup_field = PopupHelper::PopupField.new_builder(@model.model_name.param_key, col.name)
        @vc.main_app.url_for(
            controller: parent_model.model_name.collection + '_popup',
            id_target:  popup_field.id_target)
      end

      # This defines popup path for the search column on the model.
      #
      # Default returns parent model's popup-controller with id_target
      # on the search column.
      #
      # @see popup_path     popup path for the column on the model itself
      def popup_path_on_search(col)
        parent_model = @model.belongs_to_AR(col)
        raise 'Parent is nil' if !parent_model

        popup_field = PopupHelper::PopupField.new_builder(Edgarj::SearchForm.model_name.param_key, col.name)
        @vc.main_app.url_for(
            controller: parent_model.model_name.collection + '_popup',
            id_target:  popup_field.id_target)
      end

      def list_drawer_class
        Edgarj::ListDrawer::Normal
      end

      def url_for_show(record)
        @vc.url_for(action: 'show', id: record.id, format: :js)
      end

      def draw_row(record, &block)
        @vc.content_tag(:tr,
            class:  "list_line#{@line_color} edgarj_row",
            data:   {url: url_for_show(record)}) do
          yield
        end
      end

      def draw_list(list)
        @line_color = 1
        d           = list_drawer_class.new(
            self,
            @options[:list_drawer_options] || {})

        @vc.content_tag(:table, width: '100%', class: 'list') do
          @vc.content_tag(:tr) do
            ''.html_safe.tap do |result|
              for col in columns_for(list_columns) do
                result << d.draw_column_header(col)
              end
            end
          end +
          ''.html_safe.tap do |trs|
            for rec in list do
              @line_color = 1 - @line_color
              trs << draw_row(rec) do
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

      # return table_name + col.name
      def fullname(col)
        @model.table_name + '.' + col.name
      end

      # overwrite to replace form drawer for the model
      def form_drawer_class
        Edgarj::FormDrawer::Base
      end

      def draw_form(record)
        url_hash = {
          controller: @params[:controller],
          action:     record.new_record? ? 'create' : 'update',
        }
        url_hash[:id] = record.id if record.persisted?
        @vc.draw_form_buttons(@options[:draw_form_options] || {}) +
        @vc.form_for(record,
            remote: true,
            url:    url_hash,
            html:   {
                id:         '_edgarj_form',
                method:     record.new_record? ? 'post' : 'put',
                multipart:  true,
               #target:     'edgarj_form_frame'
            }) do |f|
          form_drawer_class.new(self, record, f).draw() +

          # to avoid submit on 1-textfield form when hit [ENTER] key
          '<input type="text" name="dummy" style="visibility:hidden" size=0>'.html_safe
        end
      end

      # return array of model columns (ActiveRecord::ConnectionAdapters::X_Column type).
      #
      # === INPUTS
      # column_name_list::  column name list
      def columns_for(column_name_list)
        [].tap do |result|
          for col_name in column_name_list do
            if (col = @model.columns_hash[col_name])
              result << col
            end
          end
        end
      end

      # overwrite to replace form drawer for search
      def search_form_drawer_class
        Edgarj::FormDrawer::Search
      end

      def draw_search_form(record)
        @vc.form_for(record, url: {action: 'search'}, html: {
            id:     '_edgarj_search_form',
            remote: true,
            method: :get}) do |f|
          f.fields_for(record._operator) do |o|
            search_form_drawer_class.new(self, record, f, o).draw()
          end +

          # to avoid submit on 1-textfield form when hit [ENTER] key
          '<input type="text" name="dummy" style="visibility:hidden" size=0>'.html_safe
        end
      end
    end
  end
end
