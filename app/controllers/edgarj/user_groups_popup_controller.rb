module Edgarj
  class UserGroupsPopupController < Edgarj::PopupController
  private
    def drawer_class
      UserGroupsPopupHelper::UserGroupPopupDrawer
    end
  end
end
