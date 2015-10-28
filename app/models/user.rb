class User < ActiveRecord::Base
  enum subscription_status: [:abandoned, :active, :cancelled, :charge_failed]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :encryptable,
         :recoverable, :rememberable, :trackable, :validatable
  include TokenAuthenticatable

  belongs_to :role

  validates :email, :company, presence: true
  validates :email, uniqueness: true

  after_create 'invalidate_authentication_token!'

  # Better than name(true) in cases when you need a way of identifying the user
  def identifier
    name.blank? ? email : name
  end

  # Easily address @user.name without worrying if they've provided one
  def name(response_required = false)
    name = "#{first_name} #{last_name}".strip
    name.blank? && response_required ? 'Totem User' : name
  end

  def admin?
    self.role.try(:name) == "admin"
  end

  def subscriber?
    self.role.try(:name) == "subscriber"
  end

  def super_admin?
    self.role.try(:name) == "super_admin"
  end

  def manage?
    %w(admin super_admin).include?(self.role.try(:name))
  end

  def has_role!(role_name)
    self.update_attributes(role: Role.find_or_create_by(name: role_name))
  end

  alias :subscription_status_cancelled! :cancelled!
  alias :subscription_status_active! :active!
  alias :subscription_status_abandoned! :abandoned!
  alias :subscription_status_charge_failed! :charge_failed!
  alias :subscription_status_cancelled? :cancelled?
  alias :subscription_status_active? :active?
  alias :subscription_status_abandoned? :abandoned?
  alias :subscription_status_charge_failed? :charge_failed?
end
