require 'test_helper'

class AuthorTest < ActiveSupport::TestCase
  test 'settings' do
    # test rails-app settings
    assert_equal 'Hello, World', Settings.dummy_app.hello

    # test Edgarj's settings
    assert_equal (Rails.root + 'tmp/edgarj/csv_download').to_s, Settings.edgarj.csv_dir.to_s

    # test overritten Edgarj's settings by rails-app
    assert_equal 'HELLO WORLD', Settings.edgarj._overwrite_test
  end
end
