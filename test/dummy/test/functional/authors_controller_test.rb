require 'test_helper'

class AuthorsControllerTest < ActionController::TestCase
  context 'root user' do
    setup do
      login_as(:root)
      @author = authors(:m_polanyi)
      pi = edgarj_page_infos(:root_authors)
      pi.record = Edgarj::SearchForm.new(Author, {})
      pi.save!
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
      assert_equal 2, assigns(:page_info).page
    end

    should 'sort' do
      xhr :put, :page_info_save,
        id:                 edgarj_page_infos(:root_authors).id,
        edgarj_page_info:  {
          dir:      'asc',
          order_by: 'name'
        }
      assert_response :success
      assert_not_nil assigns(:list)
      assert_equal 'asc',   assigns(:page_info).dir
      assert_equal 'name',  assigns(:page_info).order_by

      xhr :put, :page_info_save,
        id:                 edgarj_page_infos(:root_authors).id,
        edgarj_page_info:  {
          dir:      'desc',
          order_by: 'created_at'
        }
      assert_equal 'desc',        assigns(:page_info).reload.dir
      assert_equal 'created_at',  assigns(:page_info).reload.order_by
    end

    should 'create author' do
      assert_difference('Author.count') do
        xhr :post, :create, author: { name: @author.name }
      end
      assert_response :success
      assert assigns(:record)
    end

    should 'not create invalid author' do
      assert_no_difference('Author.count') do
        xhr :post, :create, author: { name: nil }
      end
      assert_response :success
      assert assigns(:record)
    end

    should 'show author in HTML' do
      get :show, id: @author
      assert_response :success
      assert_not_nil assigns(:record)
    end

    should 'show author in JS' do
      xhr :get, :show, id: @author
      assert_response :success
      assert_not_nil assigns(:record)
    end

    should 'update author' do
      assert_no_difference('Author.count') do
        xhr :put, :update, id: @author, author: { name: 'X' }
      end
      assert_response :success
      assert assigns(:record)
      assert_equal 'X', @author.reload.name
    end

    should 'destroy author' do
      assert_difference('Author.count', -1) do
        xhr :delete, :destroy, id: @author
      end
      assert_response :success
      assert assigns(:record)
      assert assigns(:list)
    end

    should 'clear' do
      assert_no_difference('Author.count') do
        xhr :get, :clear
      end
      assert_response :success
      assert_not_nil assigns(:record)
    end

    context 'search' do
      should 'search' do
        xhr :get, :search, edgarj_search_form: {_id: @author.id}
        assert_response :success
        assert_equal 1, assigns(:list).count
      end

      should 'search with operator' do
        xhr :get, :search, edgarj_search_form: {_id: @author.id},
            edgarj_search_form: {
              edgarj_search_form_operator: {
                _id: '<>'
              }
            }
        assert_response :success
        assert assigns(:list).count > 1
      end

      should 'search with timezone' do
        xhr :get, :search, edgarj_search_form: {
            created_at: '2012/09/30',
            edgarj_search_form: {
              edgarj_search_form_operator: {
                created_at: '='
              }
            }
          }
        assert_response :success
        assert assigns(:list).count == 1
      end

      should 'not search by invalid condition' do
        xhr :get, :search, edgarj_search_form: {_id: 'a'}
        assert_response :success
        assert ((l = assigns(:list))== nil || l.count == 0)
        assert !assigns(:search).valid?
      end

      should 'search_clear' do
        xhr :get, :search_clear
        assert_response :success
      end
    end

  # test Edgarj::AuthenticationMixin

    should 'current_user' do
      get :index
      assert_equal users(:root), @controller.send(:current_user)
    end
  end

  context 'read-only user' do
    setup do
      login_as(:author_reader)
      @author = authors(:m_polanyi)
      pi = edgarj_page_infos(:author_reader_authors)
      pi.record = Edgarj::SearchForm.new(Author, {})
      pi.save!
    end

    should "get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:list)
    end

    should "paginate" do
      xhr :get, :index, page: 2
      assert_response :success
      assert_not_nil assigns(:list)
    end

    should "sort" do
      xhr :put, :page_info_save,
        id:                 edgarj_page_infos(:author_reader_authors).id,
        edgarj_page_info:  {
          dir:      'asc',
          order_by: 'name'
        }
      assert_response :success
      assert_not_nil assigns(:list)
      assert_equal 'asc',   assigns(:page_info).dir
      assert_equal 'name',  assigns(:page_info).order_by
    end

    should "not create author" do
      assert_no_difference('Author.count') do
        xhr :post, :create, author: { name: @author.name }
      end
      assert_template 'message_popup'
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
    end

    should "not create author invalid" do
      assert_no_difference('Author.count') do
        xhr :post, :create, author: { name: nil }
      end
      assert_template 'message_popup'
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
    end

    should "show author in HTML" do
      get :show, id: @author
      assert_response :success
      assert_not_nil assigns(:record)
    end

    should "show author in JS" do
      xhr :get, :show, id: @author
      assert_response :success
      assert_not_nil assigns(:record)
    end

    should "not update author" do
      assert_no_difference('Author.count') do
        xhr :put, :update, id: @author, author: { name: 'X' }
      end
      assert_template 'message_popup'
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
      assert_not_equal 'X', @author.reload.name
    end

    should "not destroy author" do
      assert_no_difference('Author.count') do
        xhr :delete, :destroy, id: @author
      end
      assert_template 'message_popup'
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
    end

  # additional routes tests

    should "clear" do
      assert_no_difference('Author.count') do
        xhr :get, :clear
      end
      assert_response :success
      assert_not_nil assigns(:record)
    end

    should "csv_download" do
      get :csv_download
      assert_response :success
    end


    should 'search' do
      xhr :get, :search, edgarj_search_form: {_id: authors(:m_hagio).id}
      assert_response :success
      assert_equal 1, assigns(:list).count
    end

    should 'search_clear' do
      xhr :get, :search_clear
      assert_response :success
    end

    should 'search_save' do
      skip 'search_save'
    end

    should 'search_load' do
      skip 'search_load'
    end

=begin
    should 'zip_complete' do
      xhr :get, :zip_complete,
        zip:          '1000000',
        adrs_prefix:  :author_adrs_attributes_
      assert_response :success
      assert_equal 'Tokyo', assigns(:address).prefecture
    end
=end

  # test Edgarj::AuthenticationMixin

    should 'current_user' do
      get :index

      assert_equal users(:author_reader), @controller.send(:current_user)
    end
  end

  context 'permitted and user_scoped user' do
    setup do
      login_as(:comic_rep_01)
      @author             = authors(:m_hagio)
      @author_scoped_out  = authors(:m_polanyi)
      pi = edgarj_page_infos(:comic_rep_01_authors)
      pi.record = Edgarj::SearchForm.new(Author, {})
      pi.save!
    end

    should 'search 1 hit since role and user_scoped satisfy' do
      xhr :get, :search, edgarj_search_form: {_id: @author.id}
      assert_response :success
      assert_equal 1, assigns(:list).count
    end

    should 'not search 1 hit since key is out-of-scope' do
      xhr :get, :search, edgarj_search_form: {_id: @author_scoped_out.id}
      assert_response :success
      assert_equal 0, assigns(:list).count
    end

    should "show assigned author in HTML" do
      get :show, id: @author
      assert_response :success
      assert_not_nil assigns(:record)
    end

    should "show assigned author in JS" do
      xhr :get, :show, id: @author
      assert_response :success
      assert_not_nil assigns(:record)
    end

    should "not show non-assigned author in HTML" do
      get :show, id: @author_scoped_out
      assert_response :redirect
      assert_nil assigns(:record)
      assert_equal I18n.t('edgarj.default.not_found'), flash[:error]
    end

    should "not show non-assigned author in JS" do
      xhr :get, :show, id: @author_scoped_out
      assert_response :success
      assert_nil assigns(:record)
      assert_equal I18n.t('edgarj.default.not_found'), flash[:error]
    end

    should "update author" do
      assert_no_difference('Author.count') do
        xhr :put, :update, id: @author, author: { name: 'X' }
      end
      assert_response :success
      assert assigns(:record)
      assert_equal 'X', @author.reload.name
    end

    should "not update non-assigned author" do
      assert_no_difference('Author.count') do
        xhr :put, :update, id: @author_scoped_out, author: { name: 'X' }
      end
      assert_response :success
      assert_nil assigns(:record)
      assert_not_equal 'X', @author.reload.name
    end

    should "destroy author" do
      assert_difference('Author.count', -1) do
        xhr :delete, :destroy, id: @author
      end
      assert_response :success
      assert assigns(:record)
      assert assigns(:list)
    end

    should "not destroy non-assigned author" do
      assert_no_difference('Author.count') do
        xhr :delete, :destroy, id: @author_scoped_out
      end
      assert_response :success
      assert_nil assigns(:record)
      assert_nil assigns(:list)
    end

=begin
    should 'zip_complete' do
      xhr :get, :zip_complete,
        zip:          '1000000',
        adrs_prefix:  :author_adrs_attributes_
      assert_response :success
      assert_equal 'Tokyo', assigns(:address).prefecture
    end
=end

  end

  context 'not-permitted user' do
    setup do
      login_as(:not_permitted)
      @author = authors(:m_polanyi)
    end

    should "not get index" do
      get :index
      assert_redirected_to top_path
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
    end

    should "not paginate" do
      xhr :get, :index, page: 2
      assert_template 'message_popup'
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
    end

    should "not sort" do
      xhr :put, :page_info_save,
        id:                 edgarj_page_infos(:book_reader_authors).id,
        edgarj_page_info:  {
          dir:      'asc',
          order_by: 'name'
        }
      assert_template 'message_popup'
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
    end

    should "not create author" do
      assert_no_difference('Author.count') do
        xhr :post, :create, author: { name: @author.name }
      end
      assert_template 'message_popup'
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
    end

    should "not create author invalid" do
      assert_no_difference('Author.count') do
        xhr :post, :create, author: { name: nil }
      end

      assert_template 'message_popup'
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
    end

    should "not show author in HTML" do
      get :show, id: @author
      assert_redirected_to top_path
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
    end

    should "not show author in JS" do
      xhr :get, :show, id: @author
      assert_template 'message_popup'
      assert_equal    I18n.t('edgarj.default.permission_no'), flash[:error]
    end

    should "not update author" do
      assert_no_difference('Author.count') do
        xhr :put, :update, id: @author, author: { name: @author.name }
      end
      assert_template 'message_popup'
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
      assert_not_equal 'X', @author.reload.name
    end

    should "not destroy author" do
      assert_no_difference('Author.count') do
        xhr :delete, :destroy, id: @author
      end
      assert_template 'message_popup'
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
    end

  # additional routes tests

    should "not clear" do
      assert_no_difference('Author.count') do
        xhr :get, :clear
      end
      assert_template 'message_popup'
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
    end

    should "not csv_download" do
      get :csv_download
      assert_redirected_to top_path
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
    end

    should 'not search' do
      xhr :get, :search, edgarj_search_form: {_id: authors(:m_hagio).id}
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

=begin
    should 'not zip_complete' do
      xhr :get, :zip_complete,
        zip:          '1000000',
        adrs_prefix:  :author_adrs_attributes_
      assert_nil  assigns(:address)
      assert_template 'message_popup'
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
    end
=end

  # test Edgarj::AuthenticationMixin

    should 'current_user' do
      get :index
      assert_equal users(:not_permitted), @controller.send(:current_user)
    end
  end

  context 'not-login' do
    setup do
      @author = authors(:m_polanyi)
    end

    should "not get index" do
      get :index
      assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
    end

    should "not paginate" do
      xhr :get, :index, page: 2
      assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
    end

    should "not sort" do
      xhr :put, :page_info_save,
        id:                 edgarj_page_infos(:book_reader_authors).id,
        edgarj_page_info:  {
          dir:      'asc',
          order_by: 'name'
        }
      assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
    end

    should "not create author" do
      assert_no_difference('Author.count') do
        xhr :post, :create, author: { name: @author.name }
      end
      assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
    end

    should "not create author invalid" do
      assert_no_difference('Author.count') do
        xhr :post, :create, author: { name: nil }
      end
      assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
    end

    should "not show author in HTML" do
      get :show, id: @author
      assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
    end

    should "not show author in JS" do
      xhr :get, :show, id: @author
      assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
    end

    should "not update author" do
      assert_no_difference('Author.count') do
        xhr :put, :update, id: @author, author: { name: @author.name }
      end
      assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
    end

    should "not destroy author" do
      assert_no_difference('Author.count') do
        xhr :delete, :destroy, id: @author
      end
      assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
    end

  # additional routes tests

    should "not clear" do
      assert_no_difference('Author.count') do
        xhr :get, :clear
      end
      assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
    end

    should "not csv_download" do
      get :csv_download
      assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
    end

    should 'not search' do
      xhr :get, :search, edgarj_search_form: {_id: authors(:m_hagio).id}
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

=begin
    should 'not zip_complete' do
      xhr :get, :zip_complete,
        zip:          '1000000',
        adrs_prefix:  :author_adrs_attributes_
      assert_template 'edgarj/sssns/new'
      assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
    end
=end

  # test Edgarj::AuthenticationMixin

    should 'be nil current_user' do
      get :index
      assert_nil @controller.send(:current_user)
    end
  end

# test Edgarj::ControllerMixinForApp

  test 'v' do
    assert_equal 'Test Word!', @controller.send(:v, 'test_word')
  end
end
