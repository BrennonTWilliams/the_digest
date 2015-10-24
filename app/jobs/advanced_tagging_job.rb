require 'alchemy_api'
require 'sidekiq'

class AdvancedTaggingJob < ActiveJob::Base
  queue_as :default

  ALC_API_KEY = '468a25b29d0a2637f083c0fa0b69d42997a139e3'
  IND_API_KEY = '98cc12f49a1bad14f1452d11151b99df'
  MIN_RELEVANCE = 0.5

  def perform(*args)
  	@articles = Article.all

    for article in @articles
    	find_concepts_entities(article)
		generate_indico_tags(article)
		generate_indico_keywords(article)
		find_concepts_entities(article)
		article.save
	end
  end

  def generate_indico_tags(article)
		Indico.api_key = IND_API_KEY

		if article.summary != "" # If summary present
			ind_tags = Indico.text_tags article.summary
		else
			ind_tags = Indico.text_tags article.title
		end
		top_ind_tags = ind_tags.sort_by { |_k, v| -1.0 * v }.first(2).to_h.keys
		add_tags_from_array(article, top_ind_tags)
	end

	def generate_indico_keywords(article)
		Indico.api_key = IND_API_KEY

		if article.summary != "" # If summary present
			ind_keywords = Indico.keywords article.summary
		else
			ind_keywords = Indico.keywords article.title
		end
		top_ind_keywords = ind_keywords.sort_by { |_k, v| -1.0 * v }.first(2).to_h.keys
		add_tags_from_array(article, top_ind_keywords)
	end

	def find_concepts_entities(article)
		# Identifies and adds concept and entity tags
		AlchemyAPI.key = ALC_API_KEY
		tags = []
		if article.summary # If summary present
			a_concepts = AlchemyAPI::ConceptTagging.new.search(text: article.title)
		else
			a_concepts = AlchemyAPI::ConceptTagging.new.search(text: article.summary)
		end
		keywords = a_concepts #+ a_entities
		for keyword in keywords
			if keyword['relevance'].to_f > MIN_RELEVANCE
				tags << keyword['text']
			end
		end
		add_tags_from_array(article, tags.first(2))
	end

	def add_tags_from_array(article, tag_array)
		for tag in tag_array
			article.tag_list.add(tag)
		end
	end
end
