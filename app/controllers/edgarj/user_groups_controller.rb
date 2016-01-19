module Edgarj
  class UserGroupsController < Edgarj::EdgarjController
  private
    def drawer_class
      UserGroupsHelper::UserGroupDrawer
    end
  end
end

