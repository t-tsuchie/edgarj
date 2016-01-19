# coding: UTF-8

require 'edgarj/common_helper'
require 'edgarj/assoc_helper'
require 'edgarj/field_helper'
require 'edgarj/popup_helper'
require 'edgarj/form_drawer'
require 'edgarj/list_drawer'

module Edgarj
  module EdgarjHelper
    include CommonHelper
    include AssocHelper
    include FieldHelper
    include PopupHelper
    include FormDrawer
    include ListDrawer
    include SearchHelper
  end
end
