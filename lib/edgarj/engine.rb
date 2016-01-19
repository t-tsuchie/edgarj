require 'core_ext/resources'

module Edgarj
  class Engine < ::Rails::Engine
    config.app_generators do |g|
      g.templates.unshift File::expand_path('../templates', __FILE__)
    end

    # load this engine's config
    # (rails_config default loads from only Rails.root/config/...)
    def self.load_config
      engine_config_dir = Pathname.new(File.expand_path('../../../config', __FILE__))
      Settings.prepend_source!((engine_config_dir + 'settings.yml').to_s)
      Settings.prepend_source!((engine_config_dir + "settings/#{Rails.env}.yml").to_s)
      Settings.reload!
    end

    # Require/load application side edgarj config in RAILS_ROOT/config/edgarj/
    def self.load_edgarj_conf_in_app
      [
        Dir.glob(File.join(Rails.root, "config/edgarj/**/*.rb"))
      ].flatten.each do |edgarj_conf|
        Rails.application.config.cache_classes ?
            require(edgarj_conf) :
            load(edgarj_conf)
      end
    end

    # make edgarj related work directories
    def self.make_work_dir
      for dir in [Settings.edgarj.work_dir, Settings.edgarj.csv_dir] do
        FileUtils.mkdir_p(dir) if !File.directory?(dir)
      end
    end

    initializer "edgarj" do
     #ActiveRecord::SessionStore::Session.table_name = 'edgarj_sssns'
      Engine::load_config
      Engine::load_edgarj_conf_in_app
      for file in Dir.glob(File.join(File.dirname(__FILE__), "../../locale/*.yml")) do
        I18n.load_path << file
      end
      Engine::make_work_dir
    end
  end
end
