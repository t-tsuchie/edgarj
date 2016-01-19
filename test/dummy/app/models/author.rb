class Author < ActiveRecord::Base
  belongs_to :user_group, class_name: Edgarj::UserGroup
  has_many :books

  validates_presence_of :name

  # declare 'has_many :authors' at Edgarj::UserGroup here
  Edgarj::UserGroup.has_many :authors

  # 1. admin and author_reader can access all of authors
  # 1. The user, who belongs to AUTHOR_ASSIGNEE user_group, can access
  #    the authors belongs to the user_group.
  # 1. otherwise, cannot
  scope :user_scoped, lambda{|user, context, id_target|
    if user.admin? || 
       user.user_groups.where('kind=? AND name in (?)',
          Edgarj::UserGroup::Kind::ROLE,
          ['author/reader', 'author/admin']).count > 0
      where('1=1')
    else
      joins(user_group: :user_group_users).
      where(
        'edgarj_user_groups.kind'          => Edgarj::UserGroup::Kind::AUTHOR_ASSIGNEE,
        'edgarj_user_group_users.user_id'  => user.id)
    end
  }

  def initialize(attrs = {})
    super
   #self.adrs = Edgarj::Address.new if self.adrs == nil
  end
end
