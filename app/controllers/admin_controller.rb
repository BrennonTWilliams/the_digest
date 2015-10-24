class AdminController < ApplicationController

  include AdminHelper
  require 'mandrill'
  

  def getSubscribedUsers
  
    User.where(subscribed: true)
  
  end

  
  
  def email
    
    
    @sendings = []
    subscribers = getSubscribedUsers
    subscribers.each do |subscriber|
      
      @sendings << email_digest(subscriber)
      
    end
  
  
  end
  
  
  



end
