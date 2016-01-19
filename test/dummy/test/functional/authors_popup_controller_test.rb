require 'test_helper'

class AuthorsPopupControllerTest < ActionController::TestCase
  context 'root user' do
    setup do
      login_as(:root)
      @pi = create_page_info(@sssn, 'authors', Author)
    end
  
    should 'get index' do
      xhr :get, :index,
          id_target: "PARENT_MODEL_DOM_ID"
      assert_response :success
      assert_not_nil assigns(:list)
      assert_no_app_error
    end
  
    should 'paginate' do
      xhr :get, :index, page: 2,
          id_target: "PARENT_MODEL_DOM_ID"
      assert_response :success
      assert_not_nil assigns(:list)
      assert_no_app_error
    end
  
    should 'sort' do
      xhr :put, :page_info_save, id: @pi.id,
          id_target:        "PARENT_MODEL_DOM_ID",
          edgarj_page_info:  {
            dir:              'asc',
            order_by:         'created_at'
          }
      assert_response :success
      assert_not_nil assigns(:list)
      assert_equal 'asc',         assigns(:page_info).dir
      assert_equal 'created_at',  assigns(:page_info).order_by
      assert_no_app_error
    end

    should 'search' do
      xhr :get, :search, edgarj_search_form: {},
          id_target:        "PARENT_MODEL_DOM_ID"
      assert_response :success
      assert assigns(:list).count >= 1
      assert_no_app_error
    end
  end

  # All of tests in this context is skipped because it is required
  # to prepare read-only user.
  # When complete the preparation, delete the skip lines.
  context 'read-only user' do
    setup do
      # prepare fixtures of model_permissions, user_groups, and
      # user_group_users for read-only user of the
      # AuthorsController and login by him/her.
      #
      login_as(:author_reader)
      @pi = create_page_info(@sssn, 'authors', Author)
    end
  
    should 'get index' do
      skip 'get index'
      xhr :get, :index,
          id_target: "PARENT_MODEL_DOM_ID"
      assert_response :success
      assert_not_nil assigns(:list)
      assert_no_app_error
    end
  
    should 'paginate' do
      skip 'get paginate'
      xhr :get, :index, page: 2,
          id_target: "PARENT_MODEL_DOM_ID"
      assert_response :success
      assert_not_nil assigns(:list)
      assert_no_app_error
    end
  
    should 'sort' do
      skip 'sort'
      xhr :put, :page_info_save, id: @pi.id,
          id_target:        "PARENT_MODEL_DOM_ID",
          edgarj_page_info:  {
            dir:              'asc',
            order_by:         'created_at'
          }
      assert_response :success
      assert_not_nil assigns(:list)
      assert_equal 'asc',         assigns(:page_info).dir
      assert_equal 'created_at',  assigns(:page_info).order_by
      assert_no_app_error
    end

    should 'search' do
      skip 'search'
      xhr :get, :search, edgarj_search_form: {},
          id_target:        "PARENT_MODEL_DOM_ID"
      assert_response :success
      assert assigns(:list).count >= 1
      assert_no_app_error
    end
  end

  # All of tests in this context is skipped because it is required
  # to prepare 'permitted but user_scoped' user.
  # When complete the preparation, delete the skip lines.
  context 'permitted and user_scoped user' do
    setup do
      # prepare fixtures of model_permissions, user_groups, and
      # user_group_users for read-only user of the
     #login_as(:permitted_n_user_scoped_on_authors)
     #@pi = create_page_info(@sssn, 'authors', Author)
      @author             = authors(:m_polanyi)
      @author_scoped_out  = authors(:t_nangou)
    end
  
    should 'search since role and user_scoped satisfy' do
      skip 'search since role and user_scoped satisfy'
      xhr :get, :search, edgarj_search_form: {col: 'id', val: @author.id},
          id_target:        "PARENT_MODEL_DOM_ID"
      assert_response :success
      assert_equal 1, assigns(:list).count
      assert_no_app_error
    end

    should 'not search since key is out-of-scope' do
      skip 'not search since key is out-of-scope'
      xhr :get, :search, edgarj_search_form: {col: 'id', val: @author_scoped_out.id},
          id_target:        "PARENT_MODEL_DOM_ID"
      assert_response :success
      assert_equal 0, assigns(:list).count
      assert_no_app_error
    end
  end

  context 'not-permitted user' do
    setup do
      login_as(:not_permitted)
      @pi = create_page_info(@sssn, 'authors', Author)
    end

    should 'not get index' do
      xhr :get, :index,
          id_target: "PARENT_MODEL_DOM_ID"
      assert_template 'message_popup'
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
    end
  
    should 'not paginate' do
      xhr :get, :index, page: 2,
          id_target: "PARENT_MODEL_DOM_ID"
      assert_template 'message_popup'
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
    end
  
    should 'not sort' do
      xhr :put, :page_info_save, id: @pi.id,
          id_target:        "PARENT_MODEL_DOM_ID",
          edgarj_page_info:  {
            dir:              'asc',
            order_by:         'created_at'
          }
      assert_template 'message_popup'
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
    end

    should 'not search' do
      xhr :get, :search, edgarj_search_form: {},
          id_target:        "PARENT_MODEL_DOM_ID"
      assert_template 'message_popup'
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
    end
  end

  context 'not-login' do
    should 'not get index' do
      xhr :get, :index,
          id_target: "PARENT_MODEL_DOM_ID"
      assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
    end
  
    should 'not paginate' do
      xhr :get, :index, page: 2,
          id_target: "PARENT_MODEL_DOM_ID"
      assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
    end
  
    should 'not sort' do
      xhr :put, :page_info_save, id: 0,
          id_target:        "PARENT_MODEL_DOM_ID",
          edgarj_page_info:  {
            dir:              'asc',
            order_by:         'created_at'
          }
      assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
    end

    should 'not search' do
      xhr :get, :search, edgarj_search_form: {},
          id_target:        "PARENT_MODEL_DOM_ID"
      assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
    end
  end
end
