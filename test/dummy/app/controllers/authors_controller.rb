class AuthorsController < Edgarj::EdgarjController
private
  def drawer_class
    AuthorsHelper::AuthorDrawer
  end
end
