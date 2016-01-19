module Edgarj
  # Common module for EdgarjController and PopupController.
  module ControllerMixinCommon
    def self.included(klass)
      klass.before_filter :intern_sssn
    end

    # page is reset to 1 since order and/or lines/page are/is changed.
    def page_info_save
      if (@page_info = @sssn.page_infos.find_by_id(params[:id]))
        @page_info.update_attributes(page_info_params)
        @page_info.update_attribute(:page, 1)
      end
      prepare_list
    end

  private
    # return page related infomation for each controller x session.
    #
    # search_form may depend on each controller so that search_form
    # method should be defined for each controller.
    def page_info
      @page_info ||= PageInfo.intern(@sssn, controller_name, search_form)
    end

    # Only allow a trusted parameter "white list" through.
    def page_info_params
      params.require(:edgarj_page_info).permit(
        :view,
        :order_by,
        :dir,
        :page,
        :lines,
        :record_data)
    end

    # prepare followings:
    # 1. @page_info
    # 1. @count
    # 1. @list (with user_scoped if defined)
    #
    # This private method is called from both EdgarjController and
    # EdgarjPopupController to draw list.
    #
    # You can overwrite prepare_list() to show list at your controller.
    def prepare_list
      page_info
      @list = user_scoped.where(@page_info.record.conditions).
          page(@page_info.page).
          per(@page_info.lines)
      if !@page_info.order_by.blank?
        @list = @list.order(@page_info.order_by + ' ' + @page_info.dir)
      end

      @count = user_scoped.where(@page_info.record.conditions).count
    end

    # provide 2nd parameter for Model.user_scoped(user, context).
    # Default is @sssn.
    def scope_context
      @sssn
    end

    # narrow data scope on model
    #
    # Model's user_scoped parameters are as follows:
    # 1st argument::  current_user
    # 2nd argument::  scope_context method result (default = @sssn)
    # 3rd argument::  target for popup (see below for the detail)
    #
    # === 3rd argument
    # This is used to identify which column the selected value
    # on the popup is populated.
    def user_scoped
      @_user_scoped ||= model.respond_to?(:user_scoped) ?
          model.user_scoped(current_user, scope_context, params[:id_target]) :
          model
    end
  end
end
