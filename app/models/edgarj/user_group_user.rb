# UserGroup - User intersection model
#
module Edgarj
  class UserGroupUser < ActiveRecord::Base
    self.table_name = 'edgarj_user_group_users'

    belongs_to  :user_group
    belongs_to  :user

    validates_presence_of   :user_group_id
    validates_presence_of   :user_id
    validates_uniqueness_of :user_id, :scope=>:user_group_id

    def name
      self.user.name + ' of ' + self.user_group.name
    end
  end
end
