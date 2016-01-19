require "edgarj/engine"

module Edgarj
  class EdgarjError < StandardError; end
    class NoPopupTarget < EdgarjError; end

  LINES_PER_PAGE    = [2, 5, 10,20,50,100,200].freeze
  LIST_TEXT_MAX_LEN = 20

  # ActiveRecord::FixtureSet.identify へのショートカット
  def self.label(label)
    ActiveRecord::FixtureSet.identify(label)
  end
end
