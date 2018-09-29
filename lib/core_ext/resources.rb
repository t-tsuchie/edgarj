module ActionDispatch::Routing::Mapper::Resources
  # define edgarj specific routing for CRUD.
  #
  # Following declaration in config/routes.rb:
  #
  #   edgarj_resources :photos
  #
  # creates the following routes in addition to the default routes
  # in your application,
  # all mapping to the Photos controller which inherits from
  # Edgarj::EdgarjController:
  #
  #   GET       /photos/clear
  #   GET       /photos/csv_download
  #   GET       /photos/search
  #   GET       /photos/search_clear
  #   GET       /photos/zip_complete
  #   PATCH/PUT /photos/:id/page_info_save
  #
  # Where, :id is internally used for session so that client application
  # doesn't have to take care it.
  def edgarj_resources(*symbols, &block)
    resources(*symbols) do
      yield if block_given?

      collection do
        get :clear
        get :csv_download
        get :search
        get :search_clear
       #get :search_save
       #get :search_load
        get :zip_complete
      end

      member do
        put   :page_info_save
        patch :page_info_save
      end
    end

    self
  end

  # define edgarj specific routing for popup.
  #
  # Following declaration in config/routes.rb:
  #
  #   edgarj_popup_resources :photos_popup
  #
  # creates the following routes in your application,
  # all mapping to the Photos controller which inherits from
  # Edgarj::PopupController:
  #
  #   GET       /photos_popup/index
  #   GET       /photos_popup/search
  #   PATCH/PUT /photos_popup/:id/page_info_save
  #
  # Where, :id is internally used for session so that client application
  # doesn't have to take care it.
  def edgarj_popup_resources(*symbols, &block)
    resources(*symbols, only: [:index]) do
      yield if block_given?

      collection do
        get :search
      end

      member do
        put :page_info_save
      end
    end

    self
  end
end
