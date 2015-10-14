class ScraperController < ApplicationController
	def scrape
		s = Scraper.new()
		s.run_scrape()
	end
end
