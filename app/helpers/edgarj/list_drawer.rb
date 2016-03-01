# coding: UTF-8

module Edgarj
  module ListDrawer
    # Base for popup-list and normal-list column drawer
    #
    # Sub class of Drawer to draw list
    class Base
      include ERB::Util

      # * drawer        - Edgarj::Drawer::Base object
      # * options
      #
      # TODO: enum_cache は止め、グローバルに１つのキャッシュを作る。
      def initialize(drawer, options = {})
        @drawer           = drawer
        @options          = options.dup
        @vc               = drawer.vc
        @enum_cache       = {}
        @bitset_cache     = {}
        @parent_rec       = nil
        @belongs_to_link  = false   # doesn't make link on belongs_to
      end

      def draw_column_header(col, options={})
        @vc.content_tag(:th) do
          draw_column_header_sub(col, options)
        end
      end

      def draw_column(rec, col)
        @parent_rec = rec.belongs_to_AR(col)
        @vc.content_tag(:td, td_options(rec, col)) do
          # edgarj_address column is prior to draw_belongs_to() because of
          # avoiding link_to process on the 'belongs_to' column.
=begin
          if rec.class.edgarj_address?(col)
            col_name  = rec.class.get_column_name(col)
            adrs      = Edgarj::Address.find_by_id(rec.send(col_name))
            adrs ? draw_trimmed_str(adrs.name) : ''
=end
          if @parent_rec then
            if @belongs_to_link
              @vc.link_to(@parent_rec.name, @drawer.popup_path(col), remote: true)
            else
              h(@parent_rec.name)
            end
          else
            draw_normal_column(rec, col)
          end
        end
      end

    private
      # <td> options
      def td_options(rec, col)
        if @enum_cache[col.name]
          {}
        elsif @bitset_cache[col.name]
          {}
        elsif @parent_rec
          {}
        else
          if @vc.get_enum(rec.class, col)
            {}
#         elsif @vc.get_bitset(rec.class, col)
#           {}
          else
            case col.type
            when :datetime
              {}
            when :date
              {}
            when :integer
              {align: 'right'}
            when :boolean
              {align: 'center'}
            else
              {}
            end
          end
        end
      end

      # trim string when too long
      def draw_trimmed_str(str)
        s = str.split(//)
        if s.size > Edgarj::LIST_TEXT_MAX_LEN
          s = s[0..Edgarj::LIST_TEXT_MAX_LEN] << '...'
        end
        s.join('')
      end

      # draw sort link on list column header
      #
      # === INPUTS
      # col::         column data
      # options::     options to url_for
      def draw_sort(col, options={})
        label = @vc.column_label(col)
        dir   = 'asc'
        if @drawer.page_info.order_by == @drawer.fullname(col)
          # toggle direction
          if @drawer.page_info.dir == 'asc' || @drawer.page_info.dir.blank?
            label += '▲'
            dir    = 'desc'
          else
            label += '▼'
          end
        end
        @vc.link_to(label,
            {
            :controller                   => @drawer.params[:controller],
            :action                       => 'page_info_save',
            :id                           => @drawer.page_info.id,
            'edgarj_page_info[order_by]'   => @drawer.fullname(col),
            'edgarj_page_info[dir]'        => dir
            }.merge(options),
            :remote => true,
            :method => :put)
      end

      # draw list column header for both usual list and popup list
      def draw_column_header_sub(col, options={})
        parent = @drawer.model.belongs_to_AR(col)
        if parent then
          @vc.draw_belongs_to_label_sub(@drawer.model, col.name, parent)
        else
          draw_sort(col, options)
        end
      end

      # draw rec.col other than 'belongs_to'
      # 1. DateTime format is YYYY-MM-DD hh:mm:ss.
      # 1. if col.name == 'flags', it is assumed bitset.
      # 1. if col is edgarj_file, it is assumed file.
      #
      # === INPUTS
      # rec::   AR instance
      # col::   ActiveRecord::ConnectionAdapters::Column type which rec.class.columns returns
      def draw_normal_column(rec, col)
=begin
        if rec.class.edgarj_file?(col)
          file_info = FileInfo.safe_find(rec.send(col.name))
          file_info ? file_info.filename : ''
        elsif (enum = @enum_cache[col.name])
          @vc.draw_column_enum(rec, col, enum)
        elsif (bitset = @bitset_cache[col.name])
          @vc.draw_column_bitset(rec, col, bitset)
        else
=end
          if (enum = @vc.get_enum(rec.class, col))
            @enum_cache[col.name] = enum
            @vc.draw_column_enum(rec, col, enum)
=begin
          elsif (bitset = @vc.get_bitset(rec.class, col))
            @bitset_cache[col.name] = bitset
            @vc.draw_column_bitset(rec, col, bitset)
=end
          else
            case col.type
            when :datetime
              @vc.datetime_fmt(rec.send(col.name))
            when :date
              @vc.date_fmt(rec.send(col.name))
            when :integer
              h(rec.send(col.name))
            when :boolean
              rec.send(col.name) ? '√' : ''
            else
              # NOTE: rec.send(col.name) is not used since sssn.send(:data)
              # becomes hash rather than actual string-data so that following
              # split() fails for Hash.
              if str = rec.attributes[col.name]
                draw_trimmed_str(str)
              else
                ''
              end
            end
          end
       #end
      end
    end

    # Drawer for record list in Edgarj CRUD view.
    #
    class Normal < Base
      def initialize(edgarj_drawer, options = {})
        super(edgarj_drawer, options)
       #@belongs_to_link  = true    # make link on belongs_to
      end

      # <td> options
      #
      # add Edgarj.click_listCB() with base result.
      # When the column is parent, do nothing.
      def td_options(rec, col)
        super.merge(
            style:  'cursor:pointer;',
            class:  '_edgarj_list_column')
      end
    end
  end
end
