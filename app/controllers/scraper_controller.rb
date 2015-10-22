class ScraperController < ApplicationController
	def scrape
		s = Scraper.new()
		s.run_scrape()
		# Once the articles are added with basic tagging, begin advanced
		# tagging in the background
		AdvancedTaggingJob.perform_later nil
	end
end
