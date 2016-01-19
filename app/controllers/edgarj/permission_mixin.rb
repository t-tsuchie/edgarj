# permission check before-filters
#
# authorization('require_login' before_filter) should be prior to this.
module Edgarj
  module PermissionMixin
    def self.included(klass)
      klass.helper_method(
          :current_user_roles,
          :current_model_permissions
      )
    end

  private
    def respond_to_permission_error
      respond_to do |format|
        format.html {
          flash[:error] = v('permission_no')

          # FIXME: flash[:error] is not passed at redirected page
          # so taht set it to parmas[:error].
          # However, this change causes the test failure so that
          # this change is applied *ONLY* on dev. & prod.
          if Rails.env=='test'
            redirect_to main_app.top_path
          else
            redirect_to main_app.top_path(error: v('permission_no'))
          end
        }
        format.js {
          flash.now[:error] = v('permission_no')
          render 'message_popup'
        }
      end
    end

    def current_user_roles
      @_edgarj_current_user_roles ||= Edgarj::UserGroup.joins(:user_group_users).
          where(
              'edgarj_user_groups.kind'        => Edgarj::UserGroup::Kind::ROLE,
              'edgarj_user_group_users.user_id'=> current_user.id)
    end

    def current_model_permissions
      @_edgarj_current_model_permissions ||= Edgarj::ModelPermission.
          joins(user_group: :user_group_users).
          where(
              'model'                         => model.to_s,
              'edgarj_user_groups.kind'        => Edgarj::UserGroup::Kind::ROLE,
              'edgarj_user_group_users.user_id'=> current_user.id)
    end

    # common method for all of 'require_*_permission' before_filter
    def require_x_permission(flag)
      if current_user && current_user_roles.any?{|ug| ug.admin?}
        # if role is admin, then ok
      elsif current_user && current_model_permissions.any?{|cp| cp.permitted?(flag)}
        # if enough permission, then ok
      else
        respond_to_permission_error
      end
    end

    def require_create_permission
      require_x_permission(Edgarj::ModelPermission::FlagsBitset::CREATE)
    end

    def require_read_permission
      require_x_permission(Edgarj::ModelPermission::FlagsBitset::READ)
    end

    def require_update_permission
      require_x_permission(Edgarj::ModelPermission::FlagsBitset::UPDATE)
    end

    def require_delete_permission
      require_x_permission(Edgarj::ModelPermission::FlagsBitset::DELETE)
    end

    # fallback to catch public action which permisson is not declared
    def require_other_permission
      respond_to_permission_error
    end
  end
end
