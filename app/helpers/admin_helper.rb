module AdminHelper

  def email_digest(subscriber)
  
  
  
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
        
        message_body += article_email_text(article)
        
      end
      
    end
  
    # Send the message using the Madrill API.
    # Mandrill depends on a valid API key being set to the environment
    # variable MANDRILL_APIKEY. This is set in the file config/local_env.yml
    m = Mandrill::API.new
    Excon.defaults[:ssl_verify_peer] = false
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
    
  
  end


  def article_email_text(article)
  
    text = '<br><strong>Title</strong>'
    text += "<br>#{article.title}"
    text += '<br><strong>Author</strong>'
    text += "<br>#{article.author}"
    text += '<br><strong>PubDate</strong></br>'
    text += "<br>#{article.pubDate}"
    text += "<br><a href='http://localhost:3000/articles/#{article.id}'>Show More</a>"
    text += '<br><br>'
  
  end
  
  
  
  


end
