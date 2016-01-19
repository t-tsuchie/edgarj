# rescue part for EdgarjController (or ApplicationController) and
# EdgarjPopupController
#
module Edgarj
  module RescueMixin
  private
  
    # rescue callback sub method to show message by flush on normal http request
    # or by popup-dialog on Ajax request.
    def edgarj_rescue_sub(ex, message)
      logger.info(
          "#{ex.class} #{ex.message} bactrace:\n  " +
          ex.backtrace.join("\n  "))
  
      respond_to do |format|
        format.html {
          flash[:error] = message
          redirect_to top_path
        }
        format.js {
          flash.now[:error] = message
          render 'message_popup'
        }
      end
    end
  
    # rescue callback for 404
    def edgarj_rescue_404(ex)
      edgarj_rescue_sub(ex, v('not_found'))
    end
  
    # rescue callback
    def edgarj_rescue_app_error(ex)
      edgarj_rescue_sub(ex, ex.message)
    end
  end
end
