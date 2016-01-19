class BooksController < Edgarj::EdgarjController
private
  def drawer_class
    BooksHelper::BookDrawer
  end
end
