module Edgarj
  # build map: value -> label on-the-fly
  class EnumCache
    include Singleton

    def initialize
      @enum_map = {}

      # for stat
      @hit = @out = @out_of_enum = 0
    end

    # return label of 'rec.attr', where attr is enum value.
    def label(rec, attr, enum = nil)
      if !enum
        enum = rec.class.const_get(attr.to_s.camelize)
        raise(NameError, "wrong constant name #{attr}") if !enum
      end
      if !@enum_map[enum]
        @enum_map[enum] = {}
      end
      value = rec.attributes[attr.to_s]
      if label = @enum_map[enum][value]
        @hit += 1
        label
      else
        member = enum.constants.detect{|m|
                    enum.const_get(m) == value
                 }
        @enum_map[enum][value] = 
            if member
              @out += 1
              rec.class.human_const_name(enum, member)
            else
              @out_of_enum += 1
              '??'
            end
      end
    end

    # return statistic information of hit, out, out_of_enum.
    def stat
      [@hit, @out, @out_of_enum]
    end
  end
end
