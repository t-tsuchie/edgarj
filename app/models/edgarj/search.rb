module Edgarj
  # Search condition
  #
  # Abstract class to SearchForm and SearchPopup to provide common method
  # 'conditions'.
  #
  # 'Search' instance will be stored in view_status.model.
  #
  # \@errors will be used for error_messages_for helper in search-form.
  class Search
    # required at 'form_for' helper
    extend ActiveModel::Naming
    extend ActiveModel::Conversion
#   include ActiveModel::Conversion     ??
    include ActiveModel::Validations

    # to support 'human_attribute_name'
    extend ActiveModel::Translation

    # cache the map: column name -> column type
    #
    # SearchForm instance is serialized to be stored at session so that
    # another class (=Cache) is introduced to store cache information. 
    class Cache
      include Singleton

      attr_accessor :klass_hash, :hit, :miss

      def initialize
        @klass_hash = {}

        # for cache statistics
        @hit   = 0
        @miss  = 0
      end

      # report hit rate
      def klass_hash_report
        sprintf("%d/%d", @hit, @hit + @miss)
      end
    end

    attr_accessor :errors, :_klass_str

    def initialize(klass)
      @errors     = ActiveModel::Errors.new(self)
      @_klass_str = klass.to_s
    end

    # generate search-conditions from ActiveRecord attributes
    #
    # === RETURN
    # [condition_string, value_array]:: values for :conditions option on model
    def conditions
      raise "Not implemented"
    end

    def persisted?
      false
    end

  private
    # cache column type
    def column_type(col_name)
      cache = Cache.instance
      cache.klass_hash[@_klass_str] ||= {}
      if v = cache.klass_hash[@_klass_str][col_name.to_s]
        cache.hit += 1
        v
      else
        cache.miss += 1
        col = @_klass_str.constantize.columns.find{|c|
          c.name == col_name.to_s
        }
        if col
          cache.klass_hash[@_klass_str][col_name.to_s] = col.type
        end
      end
    end
  end
end
