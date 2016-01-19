module Edgarj::ControllerSupporter
  def login_as(user_symbol)
    @sssn = edgarj_sssns(user_symbol)
    @sssn.data    # because need to Edgarj::Sssn#loaded? be true to
                  # 'save' not return false
    @sssn.update_attribute(:session_id, @request.session_options[:id])
    @request.session[:user_id]  = user_symbol ? Edgarj::label(user_symbol) : nil
    @request.session[:sssn]     = true
  end

  def create_page_info(sssn, view, model_class)
    pi = Edgarj::PageInfo.create!(
        sssn_id:    sssn.id,
        view:       view,
        lines:      10,
        order_by:   '',
        dir:        '',
        page:       1) 
    pi.record = Edgarj::SearchForm.new(model_class, {})
    pi.save!
    pi
  end

  # error is raised during controller-action
  def assert_app_error(format = :html)
    assert_not_nil flash[:error]
  end

  # error is not raised during controller-action
  def assert_no_app_error
    assert_nil flash[:error]
  end
end
