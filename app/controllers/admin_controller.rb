class AdminController < ApplicationController

  require 'mandrill'

  def getSubscribedUsers
  
    User.where(subscribed: true)
  
  end

  
  
  def email
    
    Excon.defaults[:ssl_verify_peer] = false
    @sendings = []
    subscribers = getSubscribedUsers
    subscribers.each do |subscriber|
      
      
      # Get all articles which share any of the tags in the
      # subscriber's interest list
      articles = Article.tagged_with(subscriber.interest_list, :any => true).to_a
      # Only use the articles which have not been sent to this subscriber before
      sent_articles = subscriber.articles.to_a
      articles = articles - sent_articles
      
      # Sort the articles to show the most recent first
      articles.sort_by! {|a| a.pubDate }.reverse!
      
      
      if articles.count == 0
            
        message_body = 'It appears that there are no recent articles which match your interests.'
        message_body += '<br>Would you like to add some interests to your News Digest profile?'
      
      else
        
        message_body = 'Here is your news Digest!<br><br>'
        articles.first(10).each do |article|
          
          # Add an entry to articles/users join table so that the
          # article will not be sent to this user again.
          subscriber.articles << article
          
          message_body += '<br><strong>Title</strong>'
          message_body += "<br>#{article.title}"
          message_body += '<br><strong>Author</strong>'
          message_body += "<br>#{article.author}"
          message_body += "<br><a href='http://localhost:3000/articles/#{article.id}'>Show More</a>"
          message_body += '<br><br>'
        
        end
      
      end
      
      
      
      m = Mandrill::API.new
      message = {
        :subject => 'Your news digest!',
        :from_name => 'The News Digest',
        :text => 'This is an email send with Mandril!!',
        :to => [
            {
              :email => subscriber.email,
              :name => "#{subscriber.first_name} #{subscriber.last_name}"
              
            }
          ],
          :html => message_body,
          :from_email => 'admin@NewsDigest.com'
      }
      
      sending = m.messages.send message
      @sendings << sending
      
    end
  
  end
  
  
  



end
