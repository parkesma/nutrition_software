ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  
  def is_logged_in?
    !session[:user_id].nil?
  end
  

  module MyTestingDSL
    def log_in_as(user)
      post login_path, username: user.username, password: user.password
    end
    
    def log_out(user)
      
    end
  end  
  
  def new_session
    open_session do |sess|
      sess.extend(MyTestingDSL)
      return sess if block_given?
    end
  end
  
  def new_session_as(user)
    new_session do |sess|
      sess.log_in_as(user)
      return sess if block_given?
    end
  end
  
end