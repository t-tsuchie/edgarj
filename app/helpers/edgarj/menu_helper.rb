# draw Edgarj menu based on application's menu configuration
# at config/edgarj/menu_config.rb.
#
# Edgarj::MenuConfig should have 'top' module-function which returns arrays each
# entry is one of the followings:
#
# * item which contains link_to arg
# * controller menu list which contains controller name
#   * special entry is '_separator' which is not controller name, rather
#     generates just menu separator.
#
# See test/dummy/config/edgarj/menu_config.rb as an example.
#
# === SEE ALSO
# draw_menu::                   method to draw menu
#
# === FILE
# config/initializer/menu.rb::  menu configuration at application
module Edgarj::MenuHelper
  require File.join(Rails.root, 'config/edgarj/menu_config.rb')
  include Edgarj::MenuConfig

  def draw_menu
    content_tag(:ul, :id=>'edgarj_menu', :class=>'edgarj_menu') do
      out = ''
      for menu in Edgarj::MenuConfig.top
        out += content_tag(:li) do
          case menu[0]
          when :item
            draw_item(*menu[1])
          when :controller
            draw_controller_menu(menu[1], menu[2], menu[3])
          else
            "unknown menu type: #{menu[0]}"
          end
        end
      end
      out.html_safe
    end
  end

private
  # draw menu item
  #
  # === INPUTS
  # link_to_args:: link_to args
  def draw_item(*link_to_args)
    content_tag(:li) do
      link_to(
          v(link_to_args[0]),
          *link_to_args[1, link_to_args.size - 1])
    end
  end

  # draw controller menu for arg
  #
  # @param [string] name menu name
  # @param [ActionDispatch::Routing::RouteSet] route_proxy routes for url_for() method calling
  # @param [Array] menu_items array of string(menu item name)
  def draw_controller_menu(name, route_proxy, menu_items)
    link_to(v(name.to_s), '#') +
    content_tag(:ul) do
      out = ''
      for menu_item in menu_items do
        out += content_tag(:li) do
          case menu_item
          when '_separator'
            '<hr>'.html_safe
            # <hr> background doesn't work as I expected so that
            # use <div> with border color
            #'<div class=separator>x</div>'.html_safe
          else
            ctrl_str  = menu_item
            if permitted_on?(ctrl_str)
              # NOTE: controller string begins with '/' below.  This ensures
              # top name space.  See Rails API url_for().  For example,
              # Album::Book page, url is like /PREFIX/album/books/....
              # If there is no beginning '/', User controler page means Album::User.
              # This is not expected behavior at menu.
              link_to(
                  "#{ctrl_str.camelize}Controller".constantize.new.send(:human_name),
                  route_proxy.url_for(
                      controller:   '/' + ctrl_str,
                      only_path:    true))
            end
          end
        end
      end
      out.html_safe
    end
  end
end
