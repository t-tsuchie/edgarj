module Edgarj
  # 'SearchForm' instance contains search-conditions entered at search-form as:
  # 1. search conditions (mainly string, but integers for timestamp)
  #    for eash attribute of model
  # 1. operator (=, <, >, ...) for each attribute
  # 1. parent name for redraw
  #
  # Model(ActiveRecord) intance itself (e.g. Customer.new) doesn't satisfy to keep
  # search condition because:
  #
  # 1. id cannot be set because of protection.
  # 1. search condition may have operator (like '=', '>=')
  #
  # This is why SearchForm class is created.
  #
  # NOTE: model is stored in SearhForm as model_str.constantize to avoid following error:
  #   ArgumentError (undefined class/module Customer)
  #
  # === Operator
  # Operator for some search-fields (e.g. integer, date) are initialized
  # by params[:edgarj_search_form_operator].  For example, when search condition 
  # for Question screen GUI is:
  #
  #   Priority < 3
  #
  # then, params[:search] is:
  #
  #   :priority=>3, :search_form_operator=>{:priority=>'<'}
  #
  # and SearchForm object is built as:
  #
  #   s = SearchForm.new(Question, params[:search])
  #
  # and finally it generates SQL condition as follows:
  #
  #   s.conditions      # ["priority<?", 3]
  #
  # === Parent name
  # In order to hold parent object 'name' value for redraw, _parent[] hash is
  # used.  It is passed from params[:search_form_parent].
  #
  # === BUGS
  # date-type(e.g. 'created_at(1i)'=2010, 'created_at(2i)'=2, ...) and
  # datetime-type are not supported now while jQuery datepicker is OK.
  #
  class SearchForm < Edgarj::Search
    attr_accessor   :_operator, :_parent
    validate        :validate_data_type

    module Dbms
      MYSQL       = 1
      ELSE        = 99
    end

    # Store comparison-operator for each search field
    class Operator
      # required at 'fields_for' helper
      extend ActiveModel::Naming
      extend ActiveModel::Conversion

      ALLOWED = HashWithIndifferentAccess.new.tap do |a|
        %w(= <> > >= < <=).each do |op|
          a[op] = true
        end
      end

      # accepts only allowed operators to avoid SQL injection
      def initialize(attrs = {})
        @attrs = HashWithIndifferentAccess.new

        for k, v in (attrs || {}) do
          if ALLOWED[v]
            @attrs[k] = v
          end
        end
      end

      # generate a part of expression like '=?', ' in(?)', etc.
      #
      # When operator contains place-holder '?', it is not appended.
      def exp(attr)
        if @attrs[attr]
          if @attrs[attr].index('?')
            @attrs[attr]
          else
            @attrs[attr] + '?'
          end
        else
          '=?'
        end
      end

      def method_missing(method_name, *args)
        @attrs[method_name.to_sym]
      end
    end

    # Build SearchForm object from ActiveRecord 'klass' and attrs.
    #
    # === INPUTS
    # klass:: ActiveRecord
    # attrs:: hash of key=>value pair
    def initialize(klass, attrs={})
      super(klass)
      @_table_name  = klass.table_name
      @attrs        = attrs.dup
      @_operator    = Operator.new(attrs[:edgarj_search_form_operator])
      @_parent      = attrs[:search_form_parent]
    end

    # map attribute name to hash entry.
    # This mechanism is required to be used in 'form_for' helper.
    #
    # When column type is integer and has digits value, return integer.
    # This is required for selection helper.
    # Even it is integer but has no value, keeps blank.
    #
    # When attribute name ends '=', assignment to hash works.
    #
    # === EXAMPLE
    # s = Searchform.new(Product, :name=>'a')
    # s.name
    # s.conditions      # ["name=?", "a"]
    # s.name = 'b'      # method_missing('name=', 'b') is called
    # s.conditions      # ["name=?", "b"]
    #
    def method_missing(method_name, *args)
      if method_name.to_s =~ /^(.*)=$/
        @attrs[$1.to_sym] = args[0]
      else
        val = @attrs[method_name.to_sym]
        case column_type(method_name)
        when :integer
          if val =~ /^\d+$/
            val.to_i
          else
            val
          end
        else
          val
        end
      end
    end

    DEFAULT_TIMEZONE_FOR_TIMESTAMP_DATE_COMPARISON = '9'

    # Generate search-conditions.
    # Wildcard search by '*' is supported on string attribute.
    #
    # === RETURN
    # condition_string, value_array:: values for :conditions option on model
    def conditions
      return ['1=0'] if !valid?

      conds       = []
      values      = []
      for col in klass.columns do
        col_str = col_name(col)
        val     = @attrs[encode_name(col)]
        if !val.blank?
          case col.type
          when :string, :text
            if val =~ /\*$/
              conds   << col_str + ' like ?'
              values  << val.gsub(/\*$/, '%')
            else
              conds   << col_str + '=?'
              values  << val
            end
          when :datetime
            case is_dbms?
            when Dbms::MYSQL
#             conds   << col_str + @_operator.exp(encode_name(col))
              conds   << sprintf("date(%s)",
                  col_str) +
                  @_operator.exp(encode_name(col))
            else
              conds   << sprintf("date(timezone('%s',%s))",
                  DEFAULT_TIMEZONE_FOR_TIMESTAMP_DATE_COMPARISON,
                  col_str) +
                  @_operator.exp(encode_name(col))
            end
            values  << val.to_s
          when :boolean
            case is_dbms?
            when Dbms::MYSQL
              conds   << col_str + @_operator.exp(encode_name(col))
              values  << (val=='true')
            else
              conds   << col_str + @_operator.exp(encode_name(col))
              values  << val
            end
          else
            conds   << col_str + @_operator.exp(encode_name(col))
            values  << val
          end
        end
      end
      return [conds.join(' and ')] + values
    end

    def klass
      @_klass_str.constantize
    end

  private
    def is_dbms?
      @is_dbms ||=
        if (Edgarj::Sssn.connection.class.to_s =~ /mysql/i)
          Dbms::MYSQL
        else
          Dbms::ELSE
        end
    end

    # 'rec.id' is unintentionally interpreted as Object.id rather than
    # rec.attrs['id'] so encode it to _id.
    #
    # 'rec.type' has the same issue so to _type.
    #
    # === SEE ALSO
    # decode_name()
    def encode_name(col)
      if col.name == 'id'
        :_id
      elsif col.name == 'type'
        :_type
      else
        col.name.to_sym
      end
    end

    #
    # === SEE ALSO
    # encode_name()
    def decode_name(col)
    end

    # generate full-qualified column name.  Example: authors.name
    def col_name(col)
      [@_table_name, col.name].join('.')
    end

    def validate_data_type
      for col in klass.columns do
        encoded_col = encode_name(col)
        val     = @attrs[encoded_col]
        case col.type
        when :integer
          if val.present? && val !~ /^[\d\.\-]+$/
            errors.add(encoded_col, :not_an_integer)
          end
        else
        end
      end
    end
  end
end
