class AdminController < ApplicationController

  require 'mandrill'

  def getSubscribedUsers
  
    User.where(subscribed: true).to_a
  
  end

  
  
  def email
    
    Excon.defaults[:ssl_verify_peer] = false
    @sendings = []
    subscribers = getSubscribedUsers
    subscribers.each do |subscriber|
      m = Mandrill::API.new
      message = {
        :subject => 'Your news digest!',
        :from_name => 'The News Digest',
        :text => 'This is an email send with Mandril!!',
        :to => [
            {
              :email => subscriber.email,
              :name => '#{subscriber.firstname} #{subscriber.lastname}'
              
            }
          ],
          :html => 'This is your news digest',
          :from_email => 'admin@NewsDigest.com'
      }
      
      sending = m.messages.send message
      @sendings << sending
      
    end
  
  end
  
  
  



end
