# coding: UTF-8

module Edgarj
  module CommonHelper
    # Edgarj standard datetime format
    def datetime_fmt(dt)
      if dt.blank? then
        ''
      else
        I18n.l(dt, format: I18n.t('edgarj.time.format'))
      end
    end

    # Edgarj standard date format
    def date_fmt(dt)
      if dt == nil then
        ''
      else
        dt.strftime(I18n.t('date.formats.default'))
      end
    end

    # get enum Module.
    #
    # When Col(camelized argument col name) module exists, the Col is
    # assumed enum definition.
    def get_enum(model, col)
      col_name  = col.name
      if model.const_defined?(col_name.camelize, false)
        enum = model.const_get(col_name.camelize)
        enum.is_a?(Module) ? enum : nil
      else
        nil
      end
    end

    # model label with the following fallback order:
    # 1. t('view.CONTROLLER.model') if exists.
    # 1. model.human_name
    def model_label
      @controller_model ||= controller.send(:model)
      I18n.t("view.#{controller_path}.model",
          default:  @controller_model.human_name)
    end

    # column label with the following fallback order:
    # 1. t('view.CONTROLLER.MODEL.COLUMN') if exists.
    # 1. model.human_attribute_name(col.name)
    #
    # @param col_or_sym [Column, String, or Symbol]
    def column_label(col_or_sym)
      col_name =
          case col_or_sym
          when String, Symbol
            col_or_sym
          else
            col_or_sym.name
          end
      @controller_model ||= controller.send(:model)
      I18n.t(col_name,
          scope:    "view.#{controller_path}.#{@controller_model.name.underscore}",
          default:  @controller_model.human_attribute_name(col_name))
    end
  end
end
