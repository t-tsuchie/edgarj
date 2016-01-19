require 'test_helper'

module Edgarj
  class EdgarjControllerTest < ActionController::TestCase
    context 'login' do
      setup do
        login_as(:root)
      end

      should 'get top' do
        get :top
        assert_response :success
        assert_template 'edgarj/top'
      end
    end

    context 'not-login' do
      should 'redirect to login page' do
        get :top
        assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
      end
    end
  end
end
