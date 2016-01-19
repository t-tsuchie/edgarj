# Model-wide CRUD permission for role.  In other words, 
# CRUD permission for each model for each role is defined by this.
#
# This permission is used for two purposes:
#
# 1. page access permission
#    * If this object,which relates to a model by model-attribute, exists and
#      user belongs to the role (= user-group), then the controller,
#      which 'model_class' method returns the model, can be accessed.
# 1. popup access permission
#    * Popup access for a model-class is an read-permission for that.
#
# Example:
# 1. User 'u' belongs to 'x-role' Edgarj::UserGroup.
# 1. x-role has author model permission.
# 1. User 'u' can access AuthorController page.
# 1. If x-role has READ permission on author model, then
#    user 'u' can see author-popup on any 'belongs_to' related page
#    (e.g. BookController book form's author-popup).
module Edgarj
  class ModelPermission < ActiveRecord::Base
    self.table_name = 'edgarj_model_permissions'
    belongs_to      :user_group

    # define bitset on 'flags' column
    module FlagsBitset
      CREATE  = 0x01
      READ    = 0x02
      UPDATE  = 0x04
      DELETE  = 0x08
    end
    FLAGS_ALL = FlagsBitset.constants.inject(0){|sum, flag|
      sum += FlagsBitset.const_get(flag)
    }

    # return true if *ALL* requested flags are included in flags
    def permitted?(requested_flags)
      (self.flags & requested_flags) == requested_flags
    end
  end
end
