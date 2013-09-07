require 'digest/sha1'
class Admin < ActiveRecord::Base
  # establish_connection :development
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  before_save :encrypt_password

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # 设定默认的管理者
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zq20130709
  def self.add_default_admin
    admin = Admin.find_by_login("admin")
    admin = Admin.new(:login => "admin") if admin.blank?
    admin.email = "zq@alpha-it-system.com"
    admin.password = "123456"
    admin.password_confirmation = "123456"
    admin.save!
  end

  # 设定默认的管理者
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zq20130805
  def self.add_funward_admin
    admin = Admin.find_by_login("funward")
    admin = Admin.new(:login => "funward") if admin.blank?
    admin.email = "funward@db-move.com"
    admin.password = "funward"
    admin.password_confirmation = "funward"
    admin.save!
  end

  # 设定默认的管理者密码
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zq20130709
  def self.change_admin_password(login="admin", pass="123456")
    logger.info("==========change admin password to #{pass} =========")
    admin = Admin.find_by_login(login)
    return "no such login" if admin.blank?
    admin.password = pass
    admin.password_confirmation = pass
    admin.save!
  end

  # 设定默认的导入服务器
  #【引数】
  #【返値】
  #【注意】
  #【著作】by zq20130709
  # Admin.add_default_input_server_name
  def self.add_default_input_server_name
    outputs = CsvOutput.all
    outputs.each do |o|
      next if o.input_server_name.present?
      o.input_server_name = o.server_name
      o.save(false)
    end
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end
end
