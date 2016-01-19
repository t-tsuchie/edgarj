module Edgarj::MenuConfig
  def top
    [
      # kind        menu name
      [:controller, :App, Rails.application.routes, [
        # controller names
        'authors',
        'books',
        '_separator',     # special entry for separator
       #'edgarj/users',
       #'edgarj/user_groups',
       #'edgarj/user_group_users',
       #'edgarj/model_permissions',
       #'edgarj/sssns',
        '_separator',
       #'edgarj/addresses',
       #'edgarj/zip_addresses',
      ]],

      # TODO: '/logout' doesn't work on URL prefix.
      #       'logout' generates wrong logout URL on edgarj/* pages.
      #
      # kind  link_to args
      [:item, ['logout', 'logout', {method: :delete}]]
    ]
  end
  module_function :top
end
