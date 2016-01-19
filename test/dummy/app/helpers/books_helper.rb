module BooksHelper
  class BookDrawer < Edgarj::Drawer::Normal
    def initialize(view_context, params, page_info, model_class = Book)
      super
    end
  end
end
