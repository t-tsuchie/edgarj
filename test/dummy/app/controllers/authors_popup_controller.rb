class AuthorsPopupController < Edgarj::PopupController
private
  def drawer_class
    AuthorsPopupHelper::AuthorPopupDrawer
  end
end
