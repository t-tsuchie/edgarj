module Edgarj
  # Mixin for All controllers (not only Edgarj::ControllerMixin include class)
  module ControllerMixinForApp
    def self.included(klass)
      klass.helper_method :v, :url_prefix
    end

  private
    # Transform the controller name into a more humane format, using I18n.
    # I18n fallbacks work as follows (LeadsController as example):
    #
    # 1. t('activerecord.models.lead')
    # 1. t('controller.leads')
    # 1. t('lead')
    # 1. 'Lead'
    def human_name
      @human_name ||= begin
        str = controller_path
        single = str.singularize
        I18n.t(         "activerecord.models.#{model.to_s.underscore}",
          default:      I18n.t("controller.#{str}",
            default:    I18n.t(single,
              default:  single.camelize)))
      end
    end

    # application-wide rescue to log error info.
    def app_rescue
      logger.error(sprintf("error %s(%s) at %s#%s:\n%s",
         $!.class.to_s,
         $!.to_s,
         self.class.name,
         self.action_name,
         $@.join("\n")))
    end

    # set @sssn if not exist
    def intern_sssn
      @sssn ||=
          if (sid = request.session_options[:id])
            Edgarj::Sssn.find_by_session_id(sid) ||
                Edgarj::Sssn.new(session_id: sid)
          else
            Edgarj::Sssn.new
          end
    end

    # convenient t() for view.  v(KEY) fallback works as follows:
    #
    # 1. t('view.CONTROLLER.KEY') if exists.  Where, CONTROLLER
    #    is controller name.
    # 1. t('edgarj.view.CONTROLLER.KEY') if exists.
    # 1. t('edgarj.default.KEY') if exists.
    # 1. Key
    #
    def v(key)
      t(key,
          scope:    "view.#{controller_path}",
          default:  I18n.t(key,
              scope:    "edgarj.view.#{controller_path}",
              default:  I18n.t(key,
                  scope:    'edgarj.default',
                  default:  key.camelize)))
    end

    # TODO: dirty solution to support url namespace
    def url_prefix
      @url_prefix ||= '/'
    end
  end
end
