module Edgarj
  # Search condition for popup
  class SearchPopup < Edgarj::Search
    attr_accessor :klass_str, :col, :val

    validates_format_of :col, with: /\A[a-zA-Z_0-9\.]+\z/, allow_nil: true
    validate :validate_integer

    def initialize(klass, hash = nil)
      super(klass)
      @col  = hash ? hash[:col] : nil
      @val  = hash ? hash[:val] : nil
    end

    # implement to generate search-conditions
    def conditions
      return ['1=0'] if !valid?

      if @val.blank?
        []
      else
        # FIXME: assume type is just string
        op  = '=?'
        val = @val
        if val =~ /\*$/
          op  = ' like ?'
          val = @val.gsub(/\*/, '%')
        end
        ["#{@col}#{op}", val]
      end
    end

  private
    def validate_integer
      case column_type(col)
      when :integer
        if val.present? && val !~ /^[\d\.\-]+$/
          errors.add(:val, :not_an_integer)
        end
      else
      end
    end
  end
end
