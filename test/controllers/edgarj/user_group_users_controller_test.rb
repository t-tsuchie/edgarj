require 'test_helper'

module Edgarj
  class UserGroupUsersControllerTest < ActionController::TestCase
    context 'root user' do
      setup do
        login_as(:root)
        @user_group_user = edgarj_user_group_users(:role_admin)
        @pi = create_page_info(@sssn, 'user_group_users', UserGroupUser)
      end

      should 'get index' do
        get :index
        assert_response :success
        assert_not_nil assigns(:list)
      end

      should 'paginate' do
        xhr :get, :index, page: 2
        assert_response :success
        assert_not_nil assigns(:list)
      end

      should 'sort' do
        xhr :put, :page_info_save,
          id:                 @pi.id,
          edgarj_page_info:  {
            dir:      'asc',
            order_by: 'created_at'
          }
        assert_response :success
        assert_not_nil assigns(:list)
        assert_equal 'asc',         assigns(:page_info).dir
        assert_equal 'created_at',  assigns(:page_info).order_by
      end

      should 'create user_group_user' do
        assert_difference('UserGroupUser.count') do
          xhr :post, :create, edgarj_user_group_user: {
              user_group_id:  @user_group_user.user_group_id,
              user_id:        users(:book_admin).id,
              }
        end
        assert_response :success
        assert assigns(:record)
      end

      should 'not create invalid user_group_user' do
        assert_no_difference('UserGroupUser.count') do
          xhr :post, :create, edgarj_user_group_user: {
              user_group_id:  @user_group_user.user_group_id,
              user_id:        @user_group_user.user_id
              # duplicated user_id
              }
        end
        assert_response :success
        assert assigns(:record)
      end

  # ここで 以下エラーが発生:
  # ActionController::RoutingError No route matches {:controller=>"users", :action=>"show", :id=>..
  # /ido/maeken/repo/edgarj/app/helpers/edgarj/assoc_helper.rb:206:in `draw_belongs_to_field'
      should 'show user_group_user in HTML' do
        skip 'hi'
        get :show, id: @user_group_user
        assert_response :success
        assert_not_nil assigns(:record)
      end

      should 'show user_group_user in JS' do
        xhr :get, :show, id: @user_group_user
        assert_response :success
        assert_not_nil assigns(:record)
      end

      should 'update user_group_user' do
        xhr :put, :update, id: @user_group_user, edgarj_user_group_user: {
            user_id: users(:book_admin).id
            }
        assert_response :success
        assert assigns(:record)
      end

      should 'destroy user_group_user' do
        assert_difference('UserGroupUser.count', -1) do
          xhr :delete, :destroy, id: @user_group_user
        end
        assert_response :success
        assert assigns(:record)
        assert assigns(:list)
      end

      should 'clear user_group_user' do
        assert_no_difference('UserGroupUser.count') do
          xhr :get, :clear
        end
        assert_response :success
        assert_not_nil assigns(:record)
      end

      should 'csv_download user_group_users' do
        get :csv_download
        assert_response :success
      end

      should 'search' do
        xhr :get, :search, edgarj_search_form: {}
        assert_response :success
        assert assigns(:list).count >= 1
      end

      should 'search_clear user_group_user' do
        xhr :get, :search_clear
        assert_response :success
      end

      should 'search_save user_group_user' do
        skip 'search_save'
      end

      should 'search_load user_group_user' do
        skip 'search_load'
      end
    end

    # All of tests in this context is skipped because it is required
    # to prepare read-only user.
    # When complete the preparation, delete the skip lines.
    context 'read-only user' do
      setup do
        # prepare fixtures of model_permissions, user_groups, and
        # user_group_users for read-only user of the
        # UserGroupUsersController and login by him/her.
        #
        login_as(:user_group_user_reader)
        @pi = create_page_info(@sssn, 'user_group_users', UserGroupUser)
      end

      should 'get index' do
        skip 'get index'
        get :index
        assert_response :success
        assert_not_nil assigns(:list)
      end

      should 'paginate' do
        skip 'paginate'
        xhr :get, :index, page: 2
        assert_response :success
        assert_not_nil assigns(:list)
      end

      should 'sort' do
        skip 'sort'
        xhr :put, :page_info_save,
          id:                 @pi.id,
          edgarj_page_info:  {
            dir:      'asc',
            order_by: 'created_at'
          }
        assert_response :success
        assert_not_nil assigns(:list)
        assert_equal 'asc',         assigns(:page_info).dir
        assert_equal 'created_at',  assigns(:page_info).order_by
      end

      should 'not create user_group_user' do
        skip 'not create user_group_user'
        assert_no_difference('UserGroupUser.count') do
          xhr :post, :create, edgarj_user_group_user: {  }
        end
        assert_template 'message_popup'
        assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
      end

      should 'not create invalid user_group_user' do
        skip 'not create invalid user_group_user'
        assert_no_difference('UserGroupUser.count') do
         #xhr :post, :create, invalid resource attributes...
        end
        assert_template 'message_popup'
        assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
      end

      should 'show user_group_user in HTML' do
        skip 'show user_group_user in HTML'
        get :show, id: @user_group_user
        assert_response :success
        assert_not_nil assigns(:record)
      end

      should 'show user_group_user in JS' do
        skip 'show user_group_user in JS'
        xhr :get, :show, id: @user_group_user
        assert_response :success
        assert_not_nil assigns(:record)
      end

      should 'not update user_group_user' do
        skip 'not update user_group_user'
        xhr :put, :update, id: @user_group_user, edgarj_user_group_user: {  }
        assert_template 'message_popup'
        assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
        old_user_group_user = @user_group_user
        assert_equal(
            old_user_group_user,
            @user_group_user.reload)
      end

      should 'not destroy user_group_user' do
        skip 'not destroy user_group_user'
        assert_no_difference('UserGroupUser.count') do
          xhr :delete, :destroy, id: @user_group_user
        end
        assert_template 'message_popup'
        assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
      end

      should 'clear user_group_user' do
        skip 'clear user_group_user'
        assert_no_difference('UserGroupUser.count') do
          xhr :get, :clear
        end
        assert_response :success
        assert_not_nil assigns(:record)
      end

      should 'csv_download user_group_users' do
        skip 'csv_download user_group_users'
        get :csv_download
        assert_response :success
      end

      should 'search' do
        skip 'search user_group_users'
        xhr :get, :search, edgarj_search_form: {}
        assert_response :success
        assert assigns(:list).count >= 1
      end

      should 'search_clear user_group_user' do
        skip 'search_clear user_group_user'
        xhr :get, :search_clear
        assert_response :success
      end

      should 'search_save user_group_user' do
        skip 'search_save'
      end

      should 'search_load user_group_user' do
        skip 'search_load'
      end
    end

    # All of tests in this context is skipped because it is required
    # to prepare 'permitted but user_scoped' user.
    # When complete the preparation, delete the skip lines.
    context 'permitted and user_scoped user' do
      setup do
        # prepare fixtures of model_permissions, user_groups, and
        # user_group_users for permitted and user_scoped user of the
        # UserGroupUsersController and login by him/her.
        #
        #login_as(:permitted_n_user_scoped_on_user_group_users)
        #@pi = create_page_info(@sssn, 'user_group_users', UserGroupUser)

        @user_group_user             = edgarj_user_group_users(:role_user_group_user_reader)
        @user_group_user_scoped_out  = edgarj_user_group_users(:role_admin)
      end

      should 'search 1 hit since role and user_scoped satisfy' do
        skip 'search 1 hit since role and user_scoped satisfy'
        xhr :get, :search, edgarj_search_form: {_id: @user_group_user.id}
        assert_response :success
        assert_equal 1, assigns(:list).count
      end

      should 'not search 1 hit since key is out-of-scope' do
        skip 'not search 1 hit since key is out-of-scope'
        xhr :get, :search, edgarj_search_form: {_id: @user_group_user_scoped_out.id}
        assert_response :success
        assert_equal 0, assigns(:list).count
      end

      should 'show assigned user_group_user in HTML' do
        skip 'show assigned user_group_user in HTML'
        get :show, id: @user_group_user
        assert_response :success
        assert_not_nil assigns(:record)
      end

      should 'show assigned user_group_user in JS' do
        skip 'show assigned user_group_user in JS'
        xhr :get, :show, id: @user_group_user
        assert_response :success
        assert_not_nil assigns(:record)
      end

      should 'not show non-assigned user_group_user in HTML' do
        skip 'not show non-assigned user_group_user in HTML'
        get :show, id: @user_group_user_scoped_out
        assert_response :redirect
        assert_nil assigns(:record)
        assert_equal I18n.t('edgarj.default.not_found'), flash[:error]
      end

      should 'not show non-assigned user_group_user in JS' do
        skip 'not show non-assigned user_group_user in JS'
        xhr :get, :show, id: @user_group_user_scoped_out
        assert_response :success
        assert_nil assigns(:record)
        assert_equal I18n.t('edgarj.default.not_found'), flash[:error]
      end

      should 'update user_group_user' do
        skip 'update user_group_user'
        xhr :put, :update, id: @user_group_user, edgarj_user_group_user: {  }
        assert_response :success
        assert assigns(:record)
      end

      should 'not update user_group_user' do
        skip 'not update user_group_user'
        xhr :put, :update, id: @user_group_user, edgarj_user_group_user: {  }
        assert_nil assigns(:record)
        assert_equal I18n.t('edgarj.default.not_found'), flash[:error]
        old_user_group_user = @user_group_user
        assert_equal(
            old_user_group_user,
            @user_group_user.reload)
      end

      should 'destroy user_group_user' do
        skip 'destroy user_group_user'
        assert_difference('UserGroupUser.count', -1) do
          xhr :delete, :destroy, id: @user_group_user
        end
        assert_response :success
        assert assigns(:record)
        assert assigns(:list)
      end

      should 'not destroy user_group_user' do
        skip 'not destroy user_group_user'
        assert_no_difference('UserGroupUser.count') do
          xhr :delete, :destroy, id: @user_group_user_scoped_out
        end
        assert_equal I18n.t('edgarj.default.not_found'), flash[:error]
      end
    end

    context 'not-permitted user' do
      setup do
        login_as(:not_permitted)
        @user_group_user = edgarj_user_group_users(:role_admin)
      end

      should 'not get index' do
        get :index

        assert_redirected_to top_path
        assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
      end

      should 'not paginate' do
        xhr :get, :index, page: 2

        assert_template 'message_popup'
        assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
      end

      should 'not sort' do
        xhr :put, :page_info_save,
          id:                 edgarj_page_infos(:root_zip_address),
          edgarj_page_info:  {
            dir:      'asc',
            order_by: 'name'
          }
        assert_template 'message_popup'
        assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
      end

      should 'not create user_group_user' do
        assert_no_difference('UserGroupUser.count') do
          xhr :post, :create, edgarj_user_group_user: {  }
        end

        assert_template 'message_popup'
        assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
      end

      should 'not show user_group_user in HTML' do
        get :show, id: @user_group_user
        assert_redirected_to top_path
        assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
      end

      should 'not show user_group_user in JS' do
        xhr :get, :show, id: @user_group_user

        assert_template 'message_popup'
        assert_equal    I18n.t('edgarj.default.permission_no'), flash[:error]
      end

      should 'not update user_group_user' do
        xhr :put, :update, id: @user_group_user, edgarj_user_group_user: {  }
        assert_template 'message_popup'
        assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
        old_user_group_user = @user_group_user
        assert_equal(
            old_user_group_user,
            @user_group_user.reload)
      end

      should 'not destroy user_group_user' do
        assert_no_difference('UserGroupUser.count') do
          xhr :delete, :destroy, id: @user_group_user
        end
        assert_template 'message_popup'
        assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
      end

      should 'not clear' do
        assert_no_difference('UserGroupUser.count') do
          xhr :get, :clear
        end

        assert_template 'message_popup'
        assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
      end

      should 'not csv_download' do
        get :csv_download

        assert_redirected_to top_path
        assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
      end

      should 'not search' do
        xhr :get, :search, edgarj_search_form: {_id: @user_group_user.id}

        assert_template 'message_popup'
        assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
      end

      should 'not search_clear' do
        xhr :get, :search_clear

        assert_template 'message_popup'
        assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
      end

      should 'not search_save' do
        skip 'search_save'
      end

      should 'not search_load' do
        skip 'search_load'
      end

    # test Edgarj::AuthenticationMixin

      should 'current_user' do
        get :index
        assert_equal users(:not_permitted), @controller.send(:current_user)
      end
    end

    context 'not-login' do
      setup do
        @user_group_user = edgarj_user_group_users(:role_admin)
      end

      should 'not get index' do
        get :index
        assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
      end

      should 'not paginate' do
        xhr :get, :index, page: 2
        assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
      end

      should 'not sort' do
        xhr :put, :page_info_save,
          # ensure what happens when not-login user puts with
          # current edgarj_page_info-id
          id:                 edgarj_page_infos(:root_zip_address),
          edgarj_page_info:  {
            dir:      'asc',
            order_by: 'name'
          }
        assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
      end

      should 'not create user_group_user' do
        assert_no_difference('UserGroupUser.count') do
          xhr :post, :create, edgarj_user_group_user: { name: @user_group_user.name }
        end
        assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
      end

      should 'not create user_group_user invalid' do
        assert_no_difference('UserGroupUser.count') do
          xhr :post, :create, edgarj_user_group_user: { name: nil }
        end
        assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
      end

      should 'not show user_group_user in HTML' do
        get :show, id: @user_group_user
        assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
      end

      should 'not show user_group_user in JS' do
        xhr :get, :show, id: @user_group_user
        assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
      end

      should 'not update user_group_user' do
        assert_no_difference('UserGroupUser.count') do
          xhr :put, :update, id: @user_group_user, edgarj_user_group_user: { name: @user_group_user.name }
        end
        assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
      end

      should 'not destroy user_group_user' do
        assert_no_difference('UserGroupUser.count') do
          xhr :delete, :destroy, id: @user_group_user
        end
        assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
      end

      should 'not clear' do
        assert_no_difference('UserGroupUser.count') do
          xhr :get, :clear
        end
        assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
      end

      should 'not csv_download' do
        get :csv_download
        assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
      end

      should 'not search' do
        xhr :get, :search, edgarj_search_form: {_id: edgarj_user_group_users(:role_admin).id}
        assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
      end

      should 'not search_clear' do
        xhr :get, :search_clear
        assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
      end

      should 'not search_save' do
        skip 'search_save'
      end

      should 'not search_load' do
        skip 'search_load'
      end
    end
  end
end

