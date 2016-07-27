require 'singleton'

module Edgarj
  module Drawer
    # Column-info classes to provide the following common methods:
    #
    # * name
    # * css_style
    # * fullname
    # * column_header_label
    # * column_value
    #
    # As wells as the following for backward compatibility:
    # * type
    module ColumnInfo
      # ActiveRecord::ConnectionAdapters::[DRIVER]::Column wrapper
      #
      # NOTE: ColumnInfo::* classes instances are cached during server process
      # lifetime so that dynamic object (like drawer) cannot be stored.
      class Normal
        # @param vc     [ViewContext]
        # @param model  [AR]
        # @param name   [String]
        def initialize(vc, model, name)
          @vc             = vc
          @model          = model
          @name           = name
          @ar_column_info = model.columns_hash[name]
        end

        def name
          @name
        end

        def css_style
          case @ar_column_info.type
          when :integer
            {align: 'right'}
          when :boolean
            {align: 'center'}
          else
            {}
          end
        end

        # return table_name + col.name
        def fullname
          @model.table_name + '.' + @name
        end

        # draw column header (with sort link)
        #
        # === INPUTS
        # options::     options to url_for
        def column_header_label(page_info, options)
          label = @vc.column_label(@name)
          dir   = 'asc'

          if page_info.order_by == fullname
            # toggle direction
            if page_info.dir == 'asc' || page_info.dir.blank?
              label += '▲'
              dir    = 'desc'
            else
              label += '▼'
            end
          end
          @vc.link_to(label,
            {
              :action                       => 'page_info_save',
              :id                           => page_info.id,
              'edgarj_page_info[order_by]'  => fullname,
              'edgarj_page_info[dir]'       => dir
            }.merge(options),
            :remote => true,
            :method => :put)
        end

        # draw rec.col other than 'belongs_to'
        #
        # === INPUTS
        # rec::   AR instance
        def column_value(rec, drawer)
          if (enum = @vc.get_enum(rec.class, @ar_column_info))
            @vc.draw_column_enum(rec, @ar_column_info, enum)
          else
            case @ar_column_info.type
            when :datetime
              @vc.datetime_fmt(rec.send(name))
            when :date
              @vc.date_fmt(rec.send(name))
            when :integer
              rec.send(name).to_s
            when :boolean
              rec.send(name) ? '√' : ''
            else
              # NOTE: rec.send(col.name) is not used since sssn.send(:data)
              # becomes hash rather than actual string-data so that following
              # split() fails for Hash.
              if str = rec.attributes[name]
                draw_trimmed_str(str)
              else
                ''
              end
            end
          end
        end

        # just for backward compatibility
        def type
          @ar_column_info.type
        end

        private

        # trim string when too long
        def draw_trimmed_str(str)
          s = str.split(//)
          if s.size > Edgarj::LIST_TEXT_MAX_LEN
            s = s[0..Edgarj::LIST_TEXT_MAX_LEN] << '...'
          end
          s.join('')
        end
      end

      # auto-generated column-info for 'belongs_to' column
      #
      # parent model is assumed to have 'name' method
      class BelongsTo < Normal
        def initialize(vc, model, name, parent_model, belongs_to_link)
          super(vc, model, name)
          @parent_model     = parent_model
          @belongs_to_link  = belongs_to_link
        end

        # column header for 'belongs_to' column prints label without
        # any sort action unlike Normal-class behavior.
        def column_header_label(page_info, options)
          @vc.draw_belongs_to_label_sub(@model, name, @parent_model)
        end

        def column_value(rec, drawer)
          @parent_rec = rec.belongs_to_AR(@ar_column_info)
          if @belongs_to_link
            @vc.link_to(@parent_rec.name, drawer.popup_path(self), remote: true)
          else
            @parent_rec ? @parent_rec.name : ''
          end
        end
      end
    end

    # 'Mediator' to draw list and form of the model on the view.
    #
    # This collaborates with the following sub classes:
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
            for col in columns_for(list_columns, :list) do
              @vc.concat d.draw_column_header(col)
            end
          end +
          @vc.capture do
            for rec in list do
              @line_color = 1 - @line_color
              @vc.concat(draw_row(rec) do
                @vc.capture do
                  for col in columns_for(list_columns, :list) do
                    @vc.concat d.draw_column(rec, col)
                  end
                end
              end)
            end
          end
        end
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

      # cache ColumnInfo array per 'controller x kind'
      class ColumnInfoCache
        include Singleton

        def initialize
          #Rails.logger.debug('ColumnInfoCache initialized')
          @cache = {}
        end

        # return if @cache[controller][kind] exists
        def presence(controller, kind)
          if @cache[controller].nil?
            @cache[controller] = {}
          end
          @cache[controller][kind]
        end

        def set(controller, kind, val)
          if @cache[controller].nil?
            @cache[controller] = {}
          end
          @cache[controller][kind] = val
        end

        def cache
          @cache
        end
      end

      # return array of model columns (ActiveRecord::ConnectionAdapters::X_Column type).
      #
      # === INPUTS
      # column_name_list::  column name list
      # kind::              :list, :form, or :search_form
      def columns_for(column_name_list, kind = :default)
        if (val = ColumnInfoCache.instance.presence(@vc.controller.class, kind))
          val
        else
          #Rails.logger.debug("ColumnInfoCache non-cached access for (#{@vc.controller.class.name} x #{kind})")
          ColumnInfoCache.instance.set(@vc.controller.class, kind,
              [].tap do |result|
                for col_name in column_name_list do
                  if (col = @model.columns_hash[col_name])
                    if (parent = @model.belongs_to_AR(col))
                      result << ColumnInfo::BelongsTo.new(@vc, @model, col_name, parent, false)
                    else
                      result << ColumnInfo::Normal.new(@vc, @model, col_name)
                    end
                  end
                end
              end)
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
