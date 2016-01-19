module ActionDispatch::Routing::Mapper::Resources
  # add followings to work on Edgarj::EdgarjController derived class to
  # default resource routing:
  #
  #   collection do
  #     get :clear
  #     get :csv_download
  #     get :search
  #     get :search_clear
  #     get :search_save
  #     get :search_load
  #   end
  #
  #   member do
  #     put :page_info_save
  #   end
  #
  def edgarj_resources(*symbols, &block)
    resources *symbols do
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
        put :page_info_save
      end
    end

    self
  end

  # add followings to work on Edgarj::PopupController derived class to
  # default resource routing:
  #
  #   collection do
  #     get :clear
  #     get :csv_download
  #     get :search
  #     get :search_clear
  #     get :search_save
  #     get :search_load
  #   end
  #
  #   member do
  #     put :page_info_save
  #   end
  #
  def edgarj_popup_resources(*symbols, &block)
    resources *symbols, only: [:index] do
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
