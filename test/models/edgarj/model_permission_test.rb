require 'test_helper'

class Edgarj::ModelPermissionTest < ActiveSupport::TestCase
  test 'permitted?' do
    f     = Edgarj::ModelPermission::FlagsBitset
    TESTS = [
      # test pattern is as follows:
      #
      #expect fixture                 requested_flag(s)
      #------ -------                 -----------------
      [true,  :book_reader,           f::READ],             # exact match
      [false, :book_reader,           f::DELETE],           # exact not match
      [true,  :customer_read_update,  f::READ],             # flag is included
      [true,  :customer_read_update,  f::READ + f::UPDATE], # flags are included
      [false, :customer_read_update,  f::DELETE],           # flag is not included
      [false, :customer_read_update,  f::READ + f::DELETE], # some flags are not included
                                                            # partially -> FALSE
    ]

    for t in TESTS do
      assert_equal(
          t[0],
          !!edgarj_model_permissions(t[1]).permitted?(t[2]),
          t.inspect)
    end
  end
end
