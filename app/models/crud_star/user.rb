module CrudStar
  class User < ActiveRecord::Base
  
    validates_presence_of :username, :password, :name
    validates_uniqueness_of :username
    validates_length_of :password, :within => 8..20
  
    def self.authenticate(login, pass)
      User.find_by_username_and_password(login, User.md5(pass))
    end
  
    def self.md5(pass)
      Digest::MD5.hexdigest("--sadfsdfa-dsaf874--#{pass}")
    end
  
    def before_save
      self.password = User.md5(password)
    end
  
    def after_find
      self.password = ''
    end
  
  end
end