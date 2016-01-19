require 'test_helper'

class Edgarj::PageInfoTest < ActiveSupport::TestCase
  test 'belongs_to' do
    assert_equal edgarj_sssns(:root), edgarj_page_infos(:root_authors).sssn
  end
end
