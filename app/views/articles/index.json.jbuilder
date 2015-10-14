json.array!(@articles) do |article|
  json.extract! article, :id, :title, :author, :pubDate, :summary, :image, :source, :link, :section
  json.url article_url(article, format: :json)
end
