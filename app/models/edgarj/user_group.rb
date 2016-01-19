# UserGroup can be used for several types of user group like the followings:
#
# * user organization
# * user role
module Edgarj
  class UserGroup < ActiveRecord::Base
    self.table_name = 'edgarj_user_groups'

    acts_as_nested_set scope: :kind

    has_many  :user_group_users,  dependent: :destroy
    has_many  :users,             through: :user_group_users
    has_many  :model_permissions, dependent: :destroy

    # 'Kind' value is to identify what kind of user-group many-to-many
    # relation is established.  Following two values are reserved:
    #
    # ROLE::      controller-permission
    # USER_ORG::  organization of users
    #
    # Any uniq value can be added for application usage.  One example
    # is in test/dummy/app/decorators/models/edgarj/user_group_decorator.rb
    module Kind
      ROLE      =  100
      USER_ORG  =  200
    end

    def validate
      super
      validate_tree_kind
    end

    # return true if the role has enough permission on the controller.
    #
    # If user role is 'admin' then all operations are permitted.
    #
    # Always return false if the user-group is not ROLE.
    #
    # if requested_flags is omitted, just checks existence of
    # model_permissions and doesn't check CRUD level.
    def permitted?(model_name, requested_flags = 0)
      return false if self.kind != Kind::ROLE
      return true  if admin?

      p = self.model_permissions.find_by_model(model_name)
      if requested_flags == 0
        p
      else
        p && p.permitted?(requested_flags)
      end
    end

    def admin?
      self.kind == Kind::ROLE && name == 'admin'
    end

  private
    # USER_ORG's parent must be USER_ORG
    def validate_tree_kind
      if parent_id
        if kind != parent.kind
          err_on(:kind, 'different_kind_from_parent')
        end
      end
    end
  end
end
