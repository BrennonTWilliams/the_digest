class Scraper
	include Importers

	def run_scrape
		start_date = ::Date.today - 7
		#start_date = Article.order(created_at: :asc).first.created_at.to_date
      	end_date = ::Date.today
		scrape_guardian(start_date, end_date)
		scrape_herald_sun(start_date, end_date)
		scrape_new_yorker(start_date, end_date)
		scrape_sbs(start_date, end_date)
	end

	def scrape_sbs(start_date, end_date)
		sbs = SBSImporter.new(start_date, end_date)
		sbs_articles = sbs.scrape()
		save_to_db(sbs_articles)
	end

	def scrape_new_yorker(start_date, end_date)
		new_yorker = NewYorkerImporter.new(start_date, end_date)
		new_yorker_articles = new_yorker.scrape()
		save_to_db(new_yorker_articles)
	end

	def scrape_herald_sun(start_date, end_date)
		herald_sun = HeraldSunImporter.new(start_date, end_date)
		herald_articles = herald_sun.scrape()
		save_to_db(herald_articles)
	end

	def scrape_guardian(start_date, end_date)
		guardian = GuardianImporter.new(start_date, end_date)
		g_articles = guardian.scrape()
		save_to_db(g_articles)
	end

	def save_to_db(articles)
		for article in articles
			# Only create the Article if there is not
			# an Article with the same link already in the DB
			if not Article.find_by(link: article[:link])
				a = Article.create(article)
				a.generate_tags()
			end
		end
	end
end
