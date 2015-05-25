class User < ActiveRecord::Base
  acts_as_authorization_subject
  enum subscription_status: [:abandoned, :active, :cancelled]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :encryptable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :email, :first_name, :last_name, :company, presence: true
  validates :email, uniqueness: true

  # Better than name(true) in cases when you need a way of identifying the user
  def identifier
    name.blank? ? email : name
  end

  # Easily address @user.name without worrying if they've provided one
  def name(response_required = false)
    name = "#{first_name} #{last_name}".strip
    name.blank? && response_required ? 'Totem User' : name
  end

  alias :subscription_status_cancelled! :cancelled!
  alias :subscription_status_active! :active!
  alias :subscription_status_abandoned! :abandoned!

end
