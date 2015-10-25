module AdminHelper

  # Email a news digest to the given subscriber if there are any articles
  # which match their interests which have not been sent to them before.
  # Any articles sent will be saved in the articles_users join
  # table, so that the user will not be sent the article again.
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
        
        # Add an entry to articles_users join table so that the
        # article will not be sent to this user again.
        subscriber.articles << article
        
        message_body += article_email_text(article)
        
      end
      
    end
    

    # Create a plaintext version of the message body
    plaintext_body = message_body.gsub(/<br>/, '\r\n')
    plaintext_body.gsub!(/<a href='([^']+)'>[^<]+<\/a>/, 'See More - \1')
    plaintext_body.gsub!(/<strong>|<\/strong>/, '')
    
        

    # Send the message using the Madrill API.
    # Mandrill depends on a valid API key being set to the environment
    # variable MANDRILL_APIKEY. This is set in the file config/local_env.yml
    m = Mandrill::API.new
    # Turn off :ssl_verify_peer to prevent there being a
    # certificate verification error.
    Excon.defaults[:ssl_verify_peer] = false
    message = {
      :subject => 'Your news digest!',
      :from_name => 'The News Digest',
      :text => plaintext_body,
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

  # Return a string which presents an article for use in the email digest
  def article_email_text(article)
    
    text = '<br><strong>Title</strong>'
    text += "<br>#{article.title}"
    text += '<br><strong>Author</strong>'
    text += "<br>#{article.author}"
    text += '<br><strong>PubDate</strong>'
    text += "<br>#{article.pubDate}"
    # Link to the article's page, assuming it is being hosted
    # on http://localhost:3000
    text += "<br><a href='http://localhost:3000/articles/#{article.id}'>Show More</a>"
    text += '<br><br>'
    
  end
  

end
