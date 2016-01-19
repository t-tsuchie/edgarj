# coding: UTF-8

module Edgarj
  module SearchHelper
    # === INPUTS
    # o::       operator form builder
    # method::  column name
    def draw_search_operator(o, method)
      render '/edgarj/edgarj/search_operator',
          o:        o,
          method:   method
      end
  end
end
