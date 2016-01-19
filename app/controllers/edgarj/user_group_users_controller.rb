module Edgarj
  class UserGroupUsersController < Edgarj::EdgarjController
  private
    def drawer_class
      UserGroupUsersHelper::UserGroupUserDrawer
    end
  end
end
