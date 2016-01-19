# Modal popup controller module to pick-up 'belongs_to' record
#
# == Requrements for popup
# 1. Multiple 'belongs_to' parents for one model
# 1. Easy customize as the same as EdgarjController
module Edgarj
  class PopupController < ApplicationController
    include ControllerMixinCommon
    include Edgarj::PermissionMixin

    helper_method :model, :popup_drawer
    before_filter :require_read_permission

    # draw popup windows
    #
    # === INPUTS
    # params[:id_target]::          id target DOM on click entry of popup
    # params[:page]::               on paginate
    #
    # === Paginate logic
    # - params[:page] exists        -> save it to @page_info and use it
    # - params[:page] doesn't exist -> use @page_info.page
    #
    # === call flow
    # ==== draw popup
    # EdgarjHelper.draw_belongs_to_label() is called. Example:
    #       <a href='http://.../edgarj_popup?...' data-remote=true>Author</a>
    #       <input type=hidden name='book[author_id]'>
    #       <span id='popup_target_book_author'>...</span>
    #           :
    #
    # ==== on opening popup
    # 1. edgarj_popup URL http://.../edgarj_popup?... is executed.
    # 1. EdgarjPopupController.index() is called.
    #    1. data is searched based on @page_info and user_scoped and
    #       set it to \@list. 
    # 1. app/views/edgarj_popup/index.js.erb
    #    1. $('#edgarj_form_popup') dialog is opened.
    #
    # ==== on paginate
    # Same as above('on opening popup'), but page=N parameter is added.
    #
    # ==== on search
    # 1. post search condition to EdgarjPopupController.search().
    #
    # ==== on clicking entry on the popup
    # TBD
    def index
      page_info
      @page_info.page = (params[:page] || 1)
      prepare_list
      @search = page_info.record
    end

    # Ajax method to execute search
    #
    # Actually, this saves condition for later use.
    # Execution of search could be done at 'index' method, but
    # do it in this action to avoid 'POST' redirect issue(
    # POST method redirect resulted in 'POST index', not 'GET index').
    #
    # === INPUTS
    # params[:id_target]::          id target DOM on click entry of popup
    # params[:edgarj_search_form]::  search condition
    def search
      page_info
      @page_info.record = SearchPopup.new(model, params[:edgarj_search_form])
      @page_info.update_attribute(:page, 1)
      @search   = @page_info.record
      prepare_list  if @search.valid?
    end

  private
    # # derive model class from this controller.
    #
    # If controller cannot guess model class, overwrite this.
    #  
    # === Examples:
    # * PopupAuthorsController  -> Author
    def model
      @_model ||=
          if self.class.name =~ /^(.+)PopupController$/
            $1.singularize.constantize
          else
            raise 'Cannot guess popup model from controller'
          end
    end

    # return search-form object.
    #
    # called from page_info
    def search_form
      SearchPopup.new(model)
    end

    # drawer class of this controller.
    #
    # Derived popup controller should implement this method.
    #
    # === Examples:
    # * AuthorsController   -> AuthorPopupHelper::AuthorPopupDrawer
    def drawer_class
      raise 'Derived popup controller class should implement'
    end

    # set drawer instance as drawer for later use on rendering view
    def set_popup_drawer
      @popup_drawer = drawer_class.new(view_context, params, page_info)
    end

    def popup_drawer
      @popup_drawer
    end

    # This works as:
    #
    #   before_render :set_popup_drawer
    #
    # to set drawer just before rendering.
    #
    # See http://stackoverflow.com/questions/9281224/filter-to-execute-before-render-but-after-controller
    def render(*args)
      # set_drawer should be called only when finishing before_filters.
      set_popup_drawer if current_user
      super
    end
  end
end
