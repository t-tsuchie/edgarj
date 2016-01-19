require 'test_helper'

module Edgarj
  class UserGroupTest < ActiveSupport::TestCase
    test "permitted?" do
      TESTS = [
        #expect fixture_entry               model         operation
        [false, :user_org_top,              'any',        :READ],
        [true,  :role_admin,                'any',        :READ],
        [true,  :role_product_read_only,    'Product',    :READ],
        [false, :role_product_read_only,    'any',        :READ],
        [false, :role_product_read_only,    'Product',    :CREATE],
        [true,  :role_customer_read_update, 'Customer',   :READ],
        [true,  :role_customer_read_update, 'Customer',   :UPDATE],
        [false, :role_customer_read_update, 'Customer',   :CREATE],
        [false, :role_customer_read_update, 'Customer',   :DELETE],
        [false, :role_customer_read_update, 'any',        :READ],
        [false, :role_customer_read_update, 'any',        :CREATE],
      ]
      for t in TESTS do
        test = edgarj_user_groups(t[1]).permitted?(
            t[2],
            Edgarj::ModelPermission::FlagsBitset.const_get(t[3]))
        if t[0]
          assert test, t.inspect
        else
          assert !test, t.inspect
        end
      end
    end
  end
end
