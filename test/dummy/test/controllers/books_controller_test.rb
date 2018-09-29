require 'test_helper'

class BooksControllerTest < ActionController::TestCase
  context 'root' do
    setup do
      login_as(:root)
      @book = books(:tacit_dimension)
      pi = edgarj_page_infos(:root_books)
      pi.record = Edgarj::SearchForm.new(Book, {})
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
        id:                 edgarj_page_infos(:root_books).id,
        edgarj_page_info:  {
          dir:      'asc',
          order_by: 'name'
        }
      assert_response :success
      assert_not_nil assigns(:list)
      assert_equal 'asc',   assigns(:page_info).dir
      assert_equal 'name',  assigns(:page_info).order_by

      xhr :put, :page_info_save,
        id:                 edgarj_page_infos(:root_books).id,
        edgarj_page_info:  {
          dir:      'desc',
          order_by: 'created_at'
        }
      assert_equal 'desc',        assigns(:page_info).reload.dir
      assert_equal 'created_at',  assigns(:page_info).reload.order_by
    end

    should 'create book' do
      assert_difference('Book.count') do
        xhr :post, :create, book: { name: @book.name }
      end
      assert_response :success
      assert assigns(:record)
    end

    should 'not create invalid book' do
      assert_no_difference('Book.count') do
        xhr :post, :create, book: { name: nil }
      end
      assert_response :success
      assert assigns(:record)
    end

    should 'show book in HTML' do
      get :show, id: @book
      assert_response :success
      assert_not_nil assigns(:record)
    end

    should 'show book in JS' do
      xhr :get, :show, id: @book
      assert_response :success
      assert_not_nil assigns(:record)
    end

    should 'update book' do
      assert_no_difference('Book.count') do
        xhr :put, :update, id: @book, book: { name: 'X' }
      end
      assert_response :success
      assert assigns(:record)
      assert_equal 'X', @book.reload.name
    end

    should 'destroy book' do
      assert_difference('Book.count', -1) do
        xhr :delete, :destroy, id: @book
      end
      assert_response :success
      assert assigns(:record)
      assert assigns(:list)
    end

    should 'clear' do
      assert_no_difference('Book.count') do
        xhr :get, :clear
      end
      assert_response :success
      assert_not_nil assigns(:record)
    end

    context 'search' do
      should 'search' do
        xhr :get, :search, edgarj_search_form: {_id: @book.id}
        assert_response :success
        assert_equal 1, assigns(:list).count
      end

      should 'search with operator' do
        xhr :get, :search, edgarj_search_form: {
              _id: @book.id,
              edgarj_search_form_operator: {
                _id: '<>'
              }
            }
        assert_response :success
        assert assigns(:list).count > 1
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
      login_as(:book_reader)
      @book = books(:tacit_dimension)
      pi = edgarj_page_infos(:book_reader_books)
      pi.record = Edgarj::SearchForm.new(Book, {})
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
        id:                 edgarj_page_infos(:book_reader_books).id,
        edgarj_page_info:  {
          dir:      'asc',
          order_by: 'name'
        }
      assert_response :success
      assert_not_nil assigns(:list)
      assert_equal 'asc',   assigns(:page_info).dir
      assert_equal 'name',  assigns(:page_info).order_by
    end

    should "not create book" do
      assert_no_difference('Book.count') do
        xhr :post, :create, book: { name: @book.name }
      end
      assert_template 'message_popup'
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
    end

    should "not create book invalid" do
      assert_no_difference('Book.count') do
        xhr :post, :create, book: { name: nil }
      end
      assert_template 'message_popup'
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
    end

    should "show book in HTML" do
      get :show, id: @book
      assert_response :success
      assert_not_nil assigns(:record)
    end

    should "show book in JS" do
      xhr :get, :show, id: @book
      assert_response :success
      assert_not_nil assigns(:record)
    end

    should "not update book" do
      assert_no_difference('Book.count') do
        xhr :put, :update, id: @book, book: { name: 'X' }
      end
      assert_template 'message_popup'
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
      assert_not_equal 'X', @book.reload.name
    end

    should "not destroy book" do
      assert_no_difference('Book.count') do
        xhr :delete, :destroy, id: @book
      end
      assert_template 'message_popup'
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
    end

  # additional routes tests

    should "clear" do
      assert_no_difference('Book.count') do
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
      xhr :get, :search, edgarj_search_form: {_id: books(:tacit_dimension).id}
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
        adrs_prefix:  :book_adrs_attributes_
      assert_response :success
      assert_equal 'Tokyo', assigns(:address).prefecture
    end
=end

  # test Edgarj::AuthenticationMixin

    should 'current_user' do
      get :index

      assert_equal users(:book_reader), @controller.send(:current_user)
    end
  end

  context 'not-permitted user' do
    setup do
      login_as(:not_permitted)
      @book = books(:tacit_dimension)
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
        id:                 edgarj_page_infos(:book_reader_books).id,
        edgarj_page_info:  {
          dir:      'asc',
          order_by: 'name'
        }
      assert_template 'message_popup'
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
    end

    should "not create book" do
      assert_no_difference('Book.count') do
        xhr :post, :create, book: { name: @book.name }
      end
      assert_template 'message_popup'
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
    end

    should "not create book invalid" do
      assert_no_difference('Book.count') do
        xhr :post, :create, book: { name: nil }
      end

      assert_template 'message_popup'
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
    end

    should "not show book in HTML" do
      get :show, id: @book
      assert_redirected_to top_path
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
    end

    should "not show book in JS" do
      xhr :get, :show, id: @book
      assert_template 'message_popup'
      assert_equal    I18n.t('edgarj.default.permission_no'), flash[:error]
    end

    should "not update book" do
      assert_no_difference('Book.count') do
        xhr :put, :update, id: @book, book: { name: @book.name }
      end
      assert_template 'message_popup'
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
      assert_not_equal 'X', @book.reload.name
    end

    should "not destroy book" do
      assert_no_difference('Book.count') do
        xhr :delete, :destroy, id: @book
      end
      assert_template 'message_popup'
      assert_equal I18n.t('edgarj.default.permission_no'), flash[:error]
    end

  # additional routes tests

    should "not clear" do
      assert_no_difference('Book.count') do
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
      xhr :get, :search, edgarj_search_form: {_id: books(:tacit_dimension).id}
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
        adrs_prefix:  :book_adrs_attributes_
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
      @book = books(:tacit_dimension)
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
        id:                 edgarj_page_infos(:book_reader_books).id,
        edgarj_page_info:  {
          dir:      'asc',
          order_by: 'name'
        }
      assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
    end

    should "not create book" do
      assert_no_difference('Book.count') do
        xhr :post, :create, book: { name: @book.name }
      end
      assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
    end

    should "not create book invalid" do
      assert_no_difference('Book.count') do
        xhr :post, :create, book: { name: nil }
      end
      assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
    end

    should "not show book in HTML" do
      get :show, id: @book
      assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
    end

    should "not show book in JS" do
      xhr :get, :show, id: @book
      assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
    end

    should "not update book" do
      assert_no_difference('Book.count') do
        xhr :put, :update, id: @book, book: { name: @book.name }
      end
      assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
    end

    should "not destroy book" do
      assert_no_difference('Book.count') do
        xhr :delete, :destroy, id: @book
      end
      assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
    end

  # additional routes tests

    should "not clear" do
      assert_no_difference('Book.count') do
        xhr :get, :clear
      end
      assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
    end

    should "not csv_download" do
      get :csv_download
      assert_equal I18n.t('edgarj.default.login_failed'), flash[:error]
    end

    should 'not search' do
      xhr :get, :search, edgarj_search_form: {_id: books(:tacit_dimension).id}
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
        adrs_prefix:  :book_adrs_attributes_
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
end
