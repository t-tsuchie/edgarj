class User < ActiveRecord::Base
  attr_accessible :code, :name

  has_many :user_group_users, dependent: :destroy, class_name: 'Edgarj::UserGroupUser'
  has_many :user_groups, through: :user_group_users, class_name: 'Edgarj::UserGroup'
  has_many :sssns, dependent: :destroy, class_name: 'Edgarj::Sssn'

  def admin?
    user_groups.where(
      kind: Edgarj::UserGroup::Kind::ROLE,
      name: 'admin').count > 0
  end
end
