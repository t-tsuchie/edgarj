require 'test_helper'

module Edgarj
  class UserGroupUserTest < ActiveSupport::TestCase
    test 'name' do
      assert_not_nil edgarj_user_group_users(:role_admin).name
    end
  end
end
