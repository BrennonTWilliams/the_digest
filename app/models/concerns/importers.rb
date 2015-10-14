require 'rss'
require 'open-uri'
require 'Date'
require 'json'
require 'net/http'

module Importers
	class GuardianImporter

	# Call super in the initialize method
	def initialize start_date, end_date
		@source_name = "The Guardian"
		@url = 'http://content.guardianapis.com'
		@request_url = '/search?api-key=8gatd3pfgsqjx2raa9db5zrh&section=books'
		@default_author = 'The Guardian Staff Writers'
		@default_summary = 'Summary not provided by The Guardian'
		@start = start_date
		@end = end_date
		@articles = []
	end

	def self.source_name
		@source_name
	end

	def create_article(type, section_id, web_title, web_publication_date, id, web_url, api_url, section_name)
		@articles << {title: web_title,
			author: @default_author, pubDate: web_publication_date,
			summary: @default_summary, 
			image: nil, source: @source_name, link: web_url,
			section: section_name}
		end

		def date_valid?(pubDate)
			Date.parse(pubDate) >= @start and Date.parse(pubDate) <= @end
		end

	# Scrape method that saves article data
	# Note: The Guardian feed doesn't include images
	def scrape
		uri = URI.parse(@url)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = false
		#Make a GET request to the given url
		response = http.send_request('GET', @request_url)
		# Parse the response body
		forecast = JSON.parse(response.body)
		forecast["response"]["results"].each do |article|
			if date_valid?(article["webPublicationDate"])
				create_article(article["type"], article["sectionId"],
					article["webTitle"], article["webPublicationDate"],
					article["id"], article["webUrl"], article["apiUrl"],
					article["sectionName"])
			end
		end
		@articles
	end
end


class HeraldSunImporter

	# Call super in the initialize method
	def initialize start_date, end_date
		@source_name = ""
		@url = 'http://feeds.news.com.au/heraldsun/rss/heraldsun_news_topstories_2803.xml'
		@start = start_date
		@end = end_date
		@articles = []
	end

	# Define the class method for file_name, this should
	# return something similar to the name for your importer
	def self.source_name
		@source_name
	end

	def create_article(author, title, summary, images, source, date, link, image_length)
		@articles << {title: title, author: author,
			pubDate: date, summary: summary,
			image: images, source: source,
			link: link, section: nil}
		end

		def date_valid?(pubDate)
			if pubDate
				pubDate.to_date >= @start and pubDate.to_date <= @end
			end
		end

		def get_author(item)
			if item.source
				item.source.content
			else
			"" # Authors are not listed for some posts
		end
	end

	def get_images(item)
		if item.enclosure
			item.enclosure.url
		else
			"" # Images are not listed for some posts
		end
	end

	def get_image_length(item)
		if item.enclosure
			item.enclosure.length
		else
			"" # Images are not listed for some posts
		end
	end

	# Scrape method that saves article data
	def scrape
		open(@url) do |rss|
			feed = RSS::Parser.parse(rss)
			@source_name = feed.channel.title
			feed.items.each do |item|
				if date_valid?(item.pubDate) and item.title
					create_article(get_author(item), item.title, item.description,\
						get_images(item), @source_name, item.pubDate.to_date,\
						item.link, get_image_length(item))
				end
			end
		end
		@articles
	end
end

class NewYorkerImporter

	# Call super in the initialize method
	def initialize start_date, end_date
		@source_name = "The New Yorker Magazine"
		@url = 'http://www.newyorker.com/feed/news'
		@start = start_date
		@end = end_date
		@articles = []
	end

	# Define the class method for file_name, this should
	# return something similar to the name for your importer
	def self.source_name
		@source_name
	end

	# @articles << {title: title, author: author,
	# 		pubDate: date, summary: summary,
	# 		image: images, source: source,
	# 		link: link, section: nil}

	def create_article(author, title, summary, images, source, date, link)
		@articles << {author: author,
			title: title, summary: summary,
			image: images, source: source,
			pubDate: Date.today, link: link, section: nil}
		end

		def date_valid?(pubDate)
			pubDate.to_date >= @start and pubDate.to_date <= @end
		end

	# Scrape method that saves article data
	# Note: The New Yorker feed doesn't include images
	def scrape
		open(@url) do |rss|
			feed = RSS::Parser.parse(rss)
			@source_name = feed.channel.title
			feed.items.each do |item|
				if date_valid?(item.pubDate) and item.title
					create_article(item.dc_creator, item.title, item.description,\
						"", @source_name, item.pubDate.to_date, item.link)
				end
			end
		end
		@articles
	end
end


class SBSImporter

	# Call super in the initialize method
	def initialize start_date, end_date
		@source_name = "SBS"
		#@url = 'http://www.theage.com.au/rssheadlines/top.xml'
		#@url = 'http://www.smh.com.au/rssheadlines/top.xml'
		@url = 'http://www.sbs.com.au/news/rss/news/science-technology.xml'
		@default_section = 'science'
		@default_author = "SBS Staff Writers"
		@start = start_date
		@end = end_date
		@articles = []
	end

	# Define the class method for file_name, this should
	# return something similar to the name for your importer
	def self.source_name
		@source_name
	end

	# @articles << {title: title, author: author,
	# 		pubDate: date, summary: summary,
	# 		image: images, source: source,
	# 		link: link, section: nil}

	def create_article(author, title, summary, images, source, date, link)
		@articles << {author: author,
			title: title, summary: summary,
			image: images, source: source,
			pubDate: Date.today, link: link, section: @section}
		end

		def date_valid?(pubDate)
			pubDate.to_date >= @start and pubDate.to_date <= @end
		end

	# Scrape method that saves article data
	# Please Note: Article Author not provided by The Age
	def scrape
		open(@url) do |rss|
			feed = RSS::Parser.parse(rss)
			feed.items.each do |item|
				if date_valid?(item.pubDate) and item.title
					create_article(@default_author, item.title, item.description,\
						"", @source_name, item.pubDate.to_date, item.link)
				end
			end
		end
		@articles
	end
end



end