require 'test_helper'

module Edgarj
  class Edgarj::SssnTest < ActiveSupport::TestCase
    test 'belongs_to :user' do
      skip 'now'
      assert_equal edgarj_users(:root), edgarj_sssns(:root).user
    end
  end
end
