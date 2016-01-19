require 'test_helper'

module Edgarj
  class ModelPermissionsControllerTest < ActionController::TestCase
    context 'root user' do
      setup do
        login_as(:root)
        @edgarj_model_permission = edgarj_model_permissions(:product_read_only)
        @pi = create_page_info(@sssn, 'edgarj_model_permissions', Edgarj::ModelPermission)
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

      should 'create edgarj_model_permission' do
        assert_difference('Edgarj::ModelPermission.count') do
          xhr :post, :create, edgarj_model_permission: {flags: 0}
        end
        assert_response :success
        assert assigns(:record)
      end

      should 'not create invalid edgarj_model_permission' do
        skip 'not create invalid edgarj_model_permission'
        assert_no_difference('Edgarj::ModelPermission.count') do
         #xhr :post, :create, invalid resource attributes...
        end
        assert_response :success
        assert assigns(:record)
      end

      should 'show edgarj_model_permission in HTML' do
        get :show, id: @edgarj_model_permission
        assert_response :success
        assert_not_nil assigns(:record)
      end

      should 'show edgarj_model_permission in JS' do
        xhr :get, :show, id: @edgarj_model_permission
        assert_response :success
        assert_not_nil assigns(:record)
      end

      should 'update edgarj_model_permission' do
        xhr :put, :update, id: @edgarj_model_permission, edgarj_model_permission: {  }
        assert_response :success
        assert assigns(:record)
      end

      should 'destroy edgarj_model_permission' do
        assert_difference('Edgarj::ModelPermission.count', -1) do
          xhr :delete, :destroy, id: @edgarj_model_permission
        end
        assert_response :success
        assert assigns(:record)
        assert assigns(:list)
      end

      should 'clear edgarj_model_permission' do
        assert_no_difference('Edgarj::ModelPermission.count') do
          xhr :get, :clear
        end
        assert_response :success
        assert_not_nil assigns(:record)
      end

      should 'csv_download edgarj_model_permissions' do
        get :csv_download
        assert_response :success
      end

      should 'search' do
        xhr :get, :search, edgarj_search_form: {}
        assert_response :success
        assert assigns(:list).count >= 1
      end

      should 'search_clear edgarj_model_permission' do
        xhr :get, :search_clear
        assert_response :success
      end

      should 'search_save edgarj_model_permission' do
        skip 'search_save'
      end

      should 'search_load edgarj_model_permission' do
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
        # Edgarj::ModelPermissionsController and login by him/her.
        #
       #login_as(:edgarj_model_permission_reader)
       #@pi = create_page_info(@sssn, 'edgarj_model_permissions', Edgarj::ModelPermission)
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

      should 'not create edgarj_model_permission' do
        skip 'not create edgarj_model_permission'
        assert_no_difference('Edgarj::ModelPermission.count') do
          xhr :post, :create, edgarj_model_permission: {  }
        end
        assert_template 'message_popup'
        assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
      end

      should 'not create invalid edgarj_model_permission' do
        skip 'not create invalid edgarj_model_permission'
        assert_no_difference('Edgarj::ModelPermission.count') do
         #xhr :post, :create, invalid resource attributes...
        end
        assert_template 'message_popup'
        assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
      end

      should 'show edgarj_model_permission in HTML' do
        skip 'show edgarj_model_permission in HTML'
        get :show, id: @edgarj_model_permission
        assert_response :success
        assert_not_nil assigns(:record)
      end

      should 'show edgarj_model_permission in JS' do
        skip 'show edgarj_model_permission in JS'
        xhr :get, :show, id: @edgarj_model_permission
        assert_response :success
        assert_not_nil assigns(:record)
      end

      should 'not update edgarj_model_permission' do
        skip 'not update edgarj_model_permission'
        xhr :put, :update, id: @edgarj_model_permission, edgarj_model_permission: {  }
        assert_template 'message_popup'
        assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
        old_edgarj_model_permission = @edgarj_model_permission
        assert_equal(
            old_edgarj_model_permission,
            @edgarj_model_permission.reload)
      end

      should 'not destroy edgarj_model_permission' do
        skip 'not destroy edgarj_model_permission'
        assert_no_difference('Edgarj::ModelPermission.count') do
          xhr :delete, :destroy, id: @edgarj_model_permission
        end
        assert_template 'message_popup'
        assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
      end

      should 'clear edgarj_model_permission' do
        skip 'clear edgarj_model_permission'
        assert_no_difference('Edgarj::ModelPermission.count') do
          xhr :get, :clear
        end
        assert_response :success
        assert_not_nil assigns(:record)
      end

      should 'csv_download edgarj_model_permissions' do
        skip 'csv_download edgarj_model_permissions'
        get :csv_download
        assert_response :success
      end

      should 'search' do
        skip 'search edgarj_model_permissions'
        xhr :get, :search, edgarj_search_form: {}
        assert_response :success
        assert assigns(:list).count >= 1
      end

      should 'search_clear edgarj_model_permission' do
        skip 'search_clear edgarj_model_permission'
        xhr :get, :search_clear
        assert_response :success
      end

      should 'search_save edgarj_model_permission' do
        skip 'search_save'
      end

      should 'search_load edgarj_model_permission' do
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
        # Edgarj::ModelPermissionsController and login by him/her.
        #
        #login_as(:permitted_n_user_scoped_on_edgarj_model_permissions)
        #@pi = create_page_info(@sssn, 'edgarj_model_permissions', Edgarj::ModelPermission)

        @edgarj_model_permission             = edgarj_model_permissions(:product_read_only)
        @edgarj_model_permission_scoped_out  = edgarj_model_permissions(:book_admin)
      end

      should 'search 1 hit since role and user_scoped satisfy' do
        skip 'search 1 hit since role and user_scoped satisfy'
        xhr :get, :search, edgarj_search_form: {_id: @edgarj_model_permission.id}
        assert_response :success
        assert_equal 1, assigns(:list).count
      end

      should 'not search 1 hit since key is out-of-scope' do
        skip 'not search 1 hit since key is out-of-scope'
        xhr :get, :search, edgarj_search_form: {_id: @edgarj_model_permission_scoped_out.id}
        assert_response :success
        assert_equal 0, assigns(:list).count
      end

      should 'show assigned edgarj_model_permission in HTML' do
        skip 'show assigned edgarj_model_permission in HTML'
        get :show, id: @edgarj_model_permission
        assert_response :success
        assert_not_nil assigns(:record)
      end

      should 'show assigned edgarj_model_permission in JS' do
        skip 'show assigned edgarj_model_permission in JS'
        xhr :get, :show, id: @edgarj_model_permission
        assert_response :success
        assert_not_nil assigns(:record)
      end

      should 'not show non-assigned edgarj_model_permission in HTML' do
        skip 'not show non-assigned edgarj_model_permission in HTML'
        get :show, id: @edgarj_model_permission_scoped_out
        assert_response :redirect
        assert_nil assigns(:record)
        assert_equal I18n.t('edgarj.default.not_found'), flash[:error]
      end

      should 'not show non-assigned edgarj_model_permission in JS' do
        skip 'not show non-assigned edgarj_model_permission in JS'
        xhr :get, :show, id: @edgarj_model_permission_scoped_out
        assert_response :success
        assert_nil assigns(:record)
        assert_equal I18n.t('edgarj.default.not_found'), flash[:error]
      end

      should 'update edgarj_model_permission' do
        skip 'update edgarj_model_permission'
        xhr :put, :update, id: @edgarj_model_permission, edgarj_model_permission: {  }
        assert_response :success
        assert assigns(:record)
      end

      should 'not update edgarj_model_permission' do
        skip 'not update edgarj_model_permission'
        xhr :put, :update, id: @edgarj_model_permission, edgarj_model_permission: {  }
        assert_nil assigns(:record)
        assert_equal I18n.t('edgarj.default.not_found'), flash[:error]
        old_edgarj_model_permission = @edgarj_model_permission
        assert_equal(
            old_edgarj_model_permission,
            @edgarj_model_permission.reload)
      end

      should 'destroy edgarj_model_permission' do
        skip 'destroy edgarj_model_permission'
        assert_difference('Edgarj::ModelPermission.count', -1) do
          xhr :delete, :destroy, id: @edgarj_model_permission
        end
        assert_response :success
        assert assigns(:record)
        assert assigns(:list)
      end

      should 'not destroy edgarj_model_permission' do
        skip 'not destroy edgarj_model_permission'
        assert_no_difference('Edgarj::ModelPermission.count') do
          xhr :delete, :destroy, id: @edgarj_model_permission_scoped_out
        end
        assert_equal I18n.t('edgarj.default.not_found'), flash[:error]
      end
    end

    context 'not-permitted user' do
      setup do
        login_as(:not_permitted)
        @edgarj_model_permission = edgarj_model_permissions(:product_read_only)
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

      should 'not create edgarj_model_permission' do
        assert_no_difference('Edgarj::ModelPermission.count') do
          xhr :post, :create, edgarj_model_permission: {  }
        end

        assert_template 'message_popup'
        assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
      end

      should 'not show edgarj_model_permission in HTML' do
        get :show, id: @edgarj_model_permission
        assert_redirected_to top_path
        assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
      end

      should 'not show edgarj_model_permission in JS' do
        xhr :get, :show, id: @edgarj_model_permission

        assert_template 'message_popup'
        assert_equal    I18n.t('edgarj.default.permission_no'), flash[:error]
      end

      should 'not update edgarj_model_permission' do
        xhr :put, :update, id: @edgarj_model_permission, edgarj_model_permission: {  }
        assert_template 'message_popup'
        assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
        old_edgarj_model_permission = @edgarj_model_permission
        assert_equal(
            old_edgarj_model_permission,
            @edgarj_model_permission.reload)
      end

      should 'not destroy edgarj_model_permission' do
        assert_no_difference('Edgarj::ModelPermission.count') do
          xhr :delete, :destroy, id: @edgarj_model_permission
        end
        assert_template 'message_popup'
        assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
      end

      should 'not clear' do
        assert_no_difference('Edgarj::ModelPermission.count') do
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
        xhr :get, :search, edgarj_search_form: {_id: @edgarj_model_permission.id}

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
        @edgarj_model_permission = edgarj_model_permissions(:product_read_only)
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

      should 'not create edgarj_model_permission' do
        assert_no_difference('Edgarj::ModelPermission.count') do
          xhr :post, :create, edgarj_model_permission: { name: @edgarj_model_permission.name }
        end
        assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
      end

      should 'not create edgarj_model_permission invalid' do
        assert_no_difference('Edgarj::ModelPermission.count') do
          xhr :post, :create, edgarj_model_permission: { name: nil }
        end
        assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
      end

      should 'not show edgarj_model_permission in HTML' do
        get :show, id: @edgarj_model_permission
        assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
      end

      should 'not show edgarj_model_permission in JS' do
        xhr :get, :show, id: @edgarj_model_permission
        assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
      end

      should 'not update edgarj_model_permission' do
        assert_no_difference('Edgarj::ModelPermission.count') do
          xhr :put, :update, id: @edgarj_model_permission, edgarj_model_permission: { name: @edgarj_model_permission.name }
        end
        assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
      end

      should 'not destroy edgarj_model_permission' do
        assert_no_difference('Edgarj::ModelPermission.count') do
          xhr :delete, :destroy, id: @edgarj_model_permission
        end
        assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
      end

      should 'not clear' do
        assert_no_difference('Edgarj::ModelPermission.count') do
          xhr :get, :clear
        end
        assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
      end

      should 'not csv_download' do
        get :csv_download
        assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
      end

      should 'not search' do
        xhr :get, :search, edgarj_search_form: {_id: edgarj_model_permissions(:product_read_only).id}
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
