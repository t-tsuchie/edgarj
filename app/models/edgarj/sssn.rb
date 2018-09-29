module Edgarj
  # Edgarj specific session
  #
  # ActiveRecord::SessionStore::Session and Sssn are merged into Sssn because:
  #
  # * I could not find the way to build/prepare session for test;-(
  # * It was verbose to Sync Sssn and Session.
  #
  # See ActiveRecord::SessionStore how to do that.
  class Sssn < ActiveRecord::Base
    self.table_name = 'edgarj_sssns'

   #has_many        :cart_items,        dependent:  :destroy
   #has_many        :album_slide_shows, dependent:  :destroy,
   #                :class_name=>'Album::SlideShow'
    belongs_to      :user
    has_many        :page_infos,        dependent:  :destroy, autosave: true

  #-----------------------------------------
  # implementation section required by Rails
  #-----------------------------------------

    before_save :marshal_data!
    before_save :raise_on_session_data_overflow!

    class << self
      def data_column_size_limit
        @data_column_size_limit ||= columns_hash['data'].limit
      end

      def find_by_session_id(session_id)
        where(session_id: session_id).first
      end

      def marshal(data)
        Base64.encode64(Marshal.dump(data)) if data
      end

      def unmarshal(data)
        Marshal.load(Base64.decode64(data)) if data
      end
    end

=begin
    def initialize(attributes = nil)
      @data = nil
      super
    end
=end

    # Lazy-unmarshal session state.
    def data
      @data ||= self.class.unmarshal(read_attribute('data')) || {}
    end

    attr_writer :data

    # Has the session been loaded yet?
    def loaded?
      !!@data
    end

  private
    def marshal_data!
      return false unless loaded?
      write_attribute('data', self.class.marshal(data))
    end

    # Ensures that the data about to be stored in the database is not
    # larger than the data storage column. Raises
    # ActionController::SessionOverflowError.
    def raise_on_session_data_overflow!
      return false unless loaded?
      limit = self.class.data_column_size_limit
      if limit and read_attribute('data').size > limit
        raise ActionController::SessionOverflowError
      end
    end

  #---------------------------------------------
  # End implementation section required by Rails
  #---------------------------------------------

  public
    # delete stale sessions no longer active than SESSION_TIME_OUT minutes ago
    #
    # === INPUTS
    # dry_run:: dry-run mode (default = true)
    #
    def self.delete_stale_sessions(dry_run=true)
      self.transaction do
        for s in Sssn.all(
            :conditions=>['updated_at<?', Edgarj::BaseConfig::SESSION_TIME_OUT.minutes.ago.utc]) do
          begin
            session_id = s.session_id
            s.destroy
            logger.info("deleting session(#{session_id})")
          rescue ActiveRecord::RecordNotFound
            logger.warn("session not found(#{session_id})")
          end
        end
        raise ActiveRecord::Rollback if dry_run
      end
    end

    def name
      user.name + ' session'
    end

    def before_destroy
      if Edgarj::Login::ENABLE_LOGGING
        a         = ActionEntry.new
        a.user    = self.user
        a.action  = Action::Login.new(:kind=>Action::Login::Kind::LOGOUT)
        a.save!
      end
      true
    end
  end
end
