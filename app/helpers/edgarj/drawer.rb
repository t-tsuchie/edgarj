module Edgarj
  # Drawer is a 'presentor' and it is similar to decorator (like Draper),
  # but this simply connects model to view in order to have view-related
  # information for the model (or, to isolate view-related information
  # from the model), while decorator inherits both model and
  # view.
  module Drawer
  end
end

require 'edgarj/drawer/base'
require 'edgarj/drawer/normal'
require 'edgarj/drawer/popup'
