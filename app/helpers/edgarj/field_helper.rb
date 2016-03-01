module Edgarj
  # Edgarj::FieldHelper is independent from Edgarj default form (FormDrawer::Base)
  # so you can use helper methods here for your customized
  # form.
  module FieldHelper
    # Draw buttons for form.
    #
    # When no CREATE/UPDATE permission, save button is disabled.
    # It can be overwritten by options[:save].
    #
    # When no DELETE permission, delete button is disabled.
    # It can be overwritten by options[:delete].
    #
    # options may have:
    # :save::         html options for 'save' button.
    # :search_form::  html options for 'search_form' button.
    # :delete::       html options for 'delete' button.
    def draw_form_buttons(options = {})
      content_tag(:table) do
        content_tag(:tr) do
          # save button
          content_tag(:td) do
            #cp_bitset = Edgarj::ModelPermission::FlagsBitset
            #create_or_update = cp_bitset::CREATE + cp_bitset::UPDATE
            tag(:input, {
                type:     'button',
                name:     'save',
                onClick:  '$("#_edgarj_form").submit()',
                value:    t('edgarj.default.save'),
                class:    '_edgarj_form_save',})
               #disabled: !permitted?(create_or_update)}.merge(options[:save]||{}))
          end +

          # search button
          content_tag(:td) do
            button_for_js(t('edgarj.default.search_form'), <<-JS,
                $('#edgarj_form').hide();
                $('#edgarj_search_form').show();
              JS
              {class: '_edgarj_form_search'}.merge(options[:search_form] ||{}))
          end +

          # clear button
          content_tag(:td) do
            button_to(t('edgarj.default.clear'),
                {action: 'clear'},
                {
                  method:   :get,
                  remote:   true,
                })
          end +

          # delete button
          content_tag(:td) do
            button_to(t('edgarj.default.delete'),
                if @record.new_record?
                    url_for('/')
                else
                    url_for({
                        controller: params[:controller],
                        action:     'destroy',
                        id:         @record.id})
                end,
                {
                  method:   :delete,
                  remote:   true,
                  data:     {confirm:  t('edgarj.form.delete_confirm')},
                  disabled: @record.new_record?   # || !permitted?(cp_bitset::DELETE),
                })
          end
        end
      end
    end

    def draw_search_form_buttons
      content_tag(:table) do
        content_tag(:tr) do
          # search button
          content_tag(:td) do
            button_for_js(v('search'), '$("#_edgarj_search_form").submit()')
          end +

          # search_end button
          content_tag(:td) do
            button_for_js(v('search_end'), <<-JS)
              $('#edgarj_form').show();
              $('#edgarj_search_form').hide();
            JS
          end +

          # search_clear button
          content_tag(:td) do
            button_to(v('search_clear'),
                {action: 'search_clear'},
                {
                  method:   :get,
                  remote:   true,
                })
          end
        end
      end
    end

    def draw_search_save_popup
      render :partial => 'edgarj/search_save_popup'
    end

    # draw default field for col.type
    # 
    # options[type] is passed to each rails helper.  Following types are 
    # supported:
    # * :date
    # * :datetime
    # * :integer
    # * :boolean
    # * :text
    #
    # === INPUTS
    # f::         FormBuilder object
    # col::       column info returned by AR.columns, or symbol
    # options::   options hash passed to each helper.
    def draw_field(f, col, options={})
      case col.type
      when :date
        draw_date(f, col, options[:date] || {})
      when :datetime
        draw_datetime(f, col, options[:datetime] || {})
      when :integer
        f.text_field(col.name, options[:integer])
      else
        f.text_field(col.name, options[:text])
      end
    end

    def draw_boolean(f, col, options={})
      f.check_box(col.name, options)
    end

    # draw calendar date select
    #
    # === INPUTS
    # f::           Form builder object.
    # col_or_sym::  column object returned by rec.class.columns, or symbol
    # options::     passed to calendar_date_select
    def draw_date(f, col_or_sym, options={})
      col_name  = get_column_name(col_or_sym)
      dom_id    = sprintf("%s_%s", f.object_name, col_name)
      f.text_field(col_name, id: dom_id, size: 14) +
      javascript_tag(<<-EOJS)
        $(function(){
          $('##{dom_id}').datepicker({buttonImageOnly: true}).
              datepicker('option', {
                dateFormat:       'yy/mm/dd'
              });
        });
      EOJS
    end

    # draw calendar datetime select
    #
    # === INPUTS
    # f::           Form builder object.
    # col_or_sym::  column object returned by rec.class.columns, or symbol
    # options::     passed to calendar_date_select
    def draw_datetime(f, col_or_sym, options={})
      col_name  = get_column_name(col_or_sym)
      f.text_field(col_name,
          value: datetime_fmt(f.object.send(col_name)))
    end

    # draw 'edgarj_address' field
    #
    # The column, which is declared as 'edgarj_address', can be
    # drawn by this helper.
    #
    # === INPUTS
    # f::           FormBuilder
    # col_or_sym::  column object returned by rec.class.columns, or symbol
    def draw_address(f, col_or_sym)
      address_name  = f.object.class.get_belongs_to_name(col_or_sym)
      render('edgarj/address',
          f:            f,
          rec:          f.object,
          address_name: address_name
      )
    end

    # draw bitset checkboxes.
    #
    # When model class has integer field (e.g. 'flags') and
    # Flags module which defines 'bitflag' constant,
    # model.flags integer column is drawn as bitset checkboxes.
    # Constant name will be translated by config/locales/*.yml
    # See ModelPermission for example.
    #
    # 'flags' column value is calculated at client side by JavaScript.
    #
    # options is not used now.
    #
    # === INPUTS
    # f::       Form builder object.
    # col::     column object returned by rec.class.columns, or symbol
    # bitset::  ruby module contains 'bitflag' integer constants
    # options:: (not used)
    def draw_bitset(f, col, bitset=nil, options={})
      html          = ''
      bitset        = model.const_get(col_name.to_s.camelize + 'Bitset') if !bitset
      i             = 0
      id_array_var  = sprintf('%s_%s_var', f.object_name, col.name)
      ids           = []
      for flag in bitset.constants do
        checkbox_id = sprintf('%s_%s_%d', f.object_name, col.name, i)
        html += draw_checkbox(f, checkbox_id, flag, bitset, id_array_var) +
                label_tag(
                    checkbox_id,
                    f.object.class.human_const_name(bitset, flag)) +
                '&nbsp;&nbsp;'.html_safe
        ids << checkbox_id
        i += 1
      end
      # draw hidden field to send sum-up value
      html += f.hidden_field(col.name)

      # add hidden-field name to ids' last
      ids << sprintf("%s_%s", f.object_name, col.name)

      # define arrays to calculate flags
      html += "<script> var #{id_array_var}=[" +
                    ids.map{|id| "'" + id + "'"}.join(',') +
                "];</script>"
      html.html_safe
    end

    # draw enum selection.
    #
    # 'Enum' in Edgarj is a module which integer constants are defined.
    # draw_enum() draws selection rather than simple integer text field.
    #
    # Selection-option label is I18 supported by AR human_const_name API.
    # See lib/edgarj/model.rb rdoc.
    #
    # === EXAMPLE
    # Followings draws Question module's Priority selection
    # on @question.priority integer column:
    #
    #   <%= edgarj_form do |f| %>
    #       :
    #     <%= draw_enum(f, :priority) %>
    #       :
    #   <% end %>
    #
    # === INPUTS
    # f::           Form builder object.
    # col_or_sym::  column object returned by rec.class.columns, or symbol
    # enum::        enum module.  When nil, guess by column name.
    # options::     draw_enum options and/or passed to select helper.
    #
    # ==== Supported options
    # :choice_1st:: additional 1st choice (mainly used SearchForm enum selection)
    # :class        AR class which will be used for human_const_name()
    #
    # === SEE ALSO
    # get_enum()::          get enum definition
    # draw_column_enum()::  draw enum column in list
    #
    # FIXME: choices for selection should be cached.
    def draw_enum(f, col_or_sym, enum=nil, options={})
      col_name            =  get_column_name(col_or_sym)
      enum                = model.const_get(col_name.to_s.camelize) if !enum
      sorted_elements     = enum.constants.sort{|a,b|
                                enum.const_get(a) <=> enum.const_get(b)}
      options_for_select  = options.dup
      choice_1st          = options_for_select.delete(:choice_1st)
      class_4_human_const = options_for_select.delete(:class) || f.object.class
      f.select(col_name,
                (choice_1st ? [choice_1st] : []) +
                sorted_elements.map{|member|
                  [class_4_human_const.human_const_name(enum, member),
                   enum.const_get(member)]},
                options_for_select)
    end

    def draw_question_history(question)
      render :partial => '/questions/history', :locals=>{:question=>question}
    end

    # Field 'file_NN' in AR is handled as file attachement(upload/download) in Edgarj.
    # Where, NN is 2-digits from 00 to 99.
    #
    # draw_file() helper draws file attachment(upload/download) user-interface
    # for file_NN field.  It supports:
    #
    # 1. upload file          (Create)
    # 1. download file        (Read)
    # 1. upload another file  (Update)
    # 1. clear the field      (Delete)
    #
    # === Model
    # Integer value of file_NN column in any AR is interpreted a ID value
    # to point to a FileInfo record.
    # As NN means, any number of files (max 100) can be attached to any AR.
    #
    # belongs_to/has_one relation can be declared between the AR and FileInfo,
    # but it is not required.  Those declarations are just for your
    # customization level convenience.
    #
    # attr_accessible(or attr_protected) to hide file_NN from mass-assignment
    # *SHOULD BE* applied.
    #
    # See Report model unit test for testing.
    #
    # === INPUTS
    # f::           Form builder object.
    # col_or_sym::  column object returned by rec.class.columns, or symbol
    # options::     passed to select helper.
    #
    # === EXAMPLE
    # draw_file(f, :file_00) draws:
    #
    #   <input type=file id='file_info[file_00][uploaded_data]' ...>
    #
    # === SEE ALSO
    # ActiveRecord::Base#upsert_file_NN
    def draw_file(f, col_or_sym, options={})
      col_name  = get_column_name(col_or_sym)
      file_info = FileInfo.safe_find(f.object.send(col_name))
      error_wrapping(
        if file_info
          file_field_dom    = "file_info_#{col_name}_uploaded_data"
          file_link_dom     = "file_info_#{col_name}_link"

          file_field_sub(col_name, file_info, options.merge(:style=>'display:none')) +
          ' ' +
          content_tag(:span, :id=>file_link_dom) do
            link_to(file_info.filename,
                {:action    => 'file_download',
                 :id        => f.object.id,
                 :column    => col_name}) + ' ' +
            link_to_function("[#{t('edgarj.default.clear')}]",
                sprintf("Edgarj.clear_file('%s', '%s', '%s')",
                    file_field_dom,
                    "#{f.object_name}_#{col_name}",
                    file_link_dom))
          end +
          f.hidden_field(col_name)
        else
          file_field_sub(col_name, FileInfo.new, options)
        end, f.object.errors.on(col_name)
      )
    end

  private
    # Same as ActionView::Helpers::InstanceTag class instance method
    def error_wrapping(html_tag, has_error)
      has_error ? ActionView::Base.field_error_proc.call(html_tag, self) : html_tag
    end

    # draw Edgarj flags specific checkbox
    def draw_checkbox(f, id, flag, bitset, id_array_var)
      val       = f.object.send(:flags) || 0
      flag_val  = bitset.const_get(flag)
      tag(:input,
          type:     'checkbox',
          id:       id,
          name:     id,
          value:    flag_val,
          onChange: "Edgarj.sum_bitset(#{id_array_var})",
          checked:  (val & flag_val) != 0 )
    end

    # find column info from name
    def find_col(rec, sym)
      rec.class.columns.detect{|c| c.name == sym.to_s}
    end

    # get column name from column object or symbol
    def get_column_name(col_or_sym)
      if col_or_sym.is_a?(Symbol)
        col_or_sym
      else
        col_or_sym.name
      end
    end

    # generate following file field:
    #
    #   <input type='file' name='file_info[file_NN][uploaded_data]' ...>
    def file_field_sub(col_name, file_info, options)
      fields_for("file_info[#{col_name}]", file_info) do |f|
        f.file_field(:uploaded_data, {:size=>20}.merge(options))
      end
    end

    # replacement of button_to_function to avoid DEPRECATION WARNING.
    #
    # When the js is called just once, onClick is simpler than 
    # unobtrusive-javascript approach.
    def button_for_js(label, js, html_options={})
      tag(:input, {type: 'button', value: label, onClick: js}.merge(
        html_options))
    end
  end
end
