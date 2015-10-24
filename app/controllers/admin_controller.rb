class AdminController < ApplicationController

  include AdminHelper
  require 'mandrill'
  

  def getSubscribedUsers
  
    User.where(subscribed: true)
  
  end

  
  # Email a news digest to all subscribed users
  def email
    
    @sendings = []
    subscribers = getSubscribedUsers
    subscribers.each do |subscriber|
      # Email the digest to each subscriber, and record
      # the Mandrill response in @sendings
      @sendings << email_digest(subscriber)
      
    end
  
  end
  


end
