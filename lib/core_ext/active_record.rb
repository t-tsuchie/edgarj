# Add Edgarj specific methods.
class ActiveRecord::Base
  # cache several kind of information for each (class x kind) during runtime,
  # for example, result of edgarj_address? method.
  @@_edgarj_cache = {}

  # Fallback is as follows (Author model is an example):
  # 1. t('activerecord.author')
  # 1. t('edgarj.default.author')
  # 1. human()
  def self.human_name
    name = self.model_name
    I18n.t(name.i18n_key,
        scope:    :activerecord,
        default:  I18n.t(name.i18n_key,
            scope:   'edgarj.default',
            default: name.human))
  end

  # return AR assoc which the column belongs to.  nil if not exist
  def self.belongs_to_AR_assoc(column)
    parent_assoc_cache = edgarj_cache(:parent_assoc)
    if (parent_assoc = parent_assoc_cache[column])
      return parent_assoc
    end

    for parent_assoc in reflect_on_all_associations(:belongs_to) do
      if !parent_assoc.options[:polymorphic] &&
          parent_assoc.foreign_key.to_sym == column.name.to_sym
        parent_assoc_cache[column] = parent_assoc
        return parent_assoc
      end
    end
    nil
  end

  # return AR class which the column belongs to.  nil if not exist
  def self.belongs_to_AR(column)
    if (parent_assoc = belongs_to_AR_assoc(column))
      parent_assoc.klass
    else
      nil
    end
  end

  # Human name for 'const' in namespace of the '_module'.
  #
  # I18n fallbacks is as follows (Question::Priority::HIGH as example):
  #
  # 1. t('activerecord.enums.question/priority.HIGH')
  # 1. t('high')
  # 1. 'High'
  #
  def self.human_const_name(_module, const)
    lower = const.downcase
    I18n.t(const,
        scope:    "activerecord.enums.#{_module.name.underscore}",
        default:  I18n.t(lower,
            scope:    'edgarj.default',
            default:  lower.to_s.humanize))
  end

  # short-cut of:
  #   errors.add(attr, I18n.t(message_key, :scope=>'activerecord.errors.messages')
  def err_on(attr, message_key)
    errors.add(
        attr,
        I18n.t(message_key, :scope=>'activerecord.errors.messages'))
  end

  # get belongs_to association name from column.
  #
  # Example: get_assoc_name(:adrs_id) -> :adrs
  def self.get_belongs_to_name(col_or_sym)
    cache     = edgarj_cache(:belongs_to_name)
    col_name  = get_column_name(col_or_sym).to_s
    if !cache[col_name].nil?
      return cache[col_name]
    end

    for reflection in reflect_on_all_associations(:belongs_to) do
      if reflection.foreign_key.to_sym == col_name.to_sym
        cache[col_name] = reflection.name
        return reflection.name
      end
    end
    nil
  end

  # initialize cache per (class x kind) on the fly
  def self.edgarj_cache(kind)
    @@_edgarj_cache[self] = {}       if !@@_edgarj_cache[self]
    @@_edgarj_cache[self][kind] = {} if !@@_edgarj_cache[self][kind]
    @@_edgarj_cache[self][kind]
  end

  # just for dump purpose
  def self._edgarj_cache
    @@_edgarj_cache
  end

  # get column name from column object or symbol
  def self.get_column_name(col_or_sym)
    case col_or_sym
    when String, Symbol
      col_or_sym
    else
      col_or_sym.name
    end
  end

  # return AR object which the column belongs to.
  # return nil if the column is not 'belongs_to'
  #
  # @see self.belongs_to_AR
  def belongs_to_AR(column)
    if (parent_assoc = self.class.belongs_to_AR_assoc(column))
      send(parent_assoc.name)
    else
      nil
    end
  end
end
