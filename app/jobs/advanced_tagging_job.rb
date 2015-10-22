require 'alchemy_api'

class AdvancedTaggingJob < ActiveJob::Base
  queue_as :default

  ALC_API_KEY = '468a25b29d0a2637f083c0fa0b69d42997a139e3'
  IND_API_KEY = '98cc12f49a1bad14f1452d11151b99df'
  MIN_RELEVANCE = 0.5

  def perform(*args)
  	@articles = Article.all
  	puts "*"*100
    puts "RUNNING BACKGROUND JOB"

    for article in @articles
    	find_concepts_entities(article)
		generate_indico_keywords(article)
		article.save
	end
  end

  def generate_indico_keywords(article)
		Indico.api_key = API_KEY
		#ind_keywords = Indico.keywords article.summary
		if article.source == "The Guardian" # Doesn't provide summaries
			ind_tags = Indico.text_tags article.title
		else
			ind_tags = Indico.text_tags article.summary
		end
		add_tags_from_array(ind_tags)
	end

	def find_concepts_entities(article)
		# Identifies and adds concept and entity tags
		AlchemyAPI.key = ALC_API_KEY
		tags = []
		#a_entities = AlchemyAPI::EntityExtraction.new.search(text: article.summary)
		#a_entities.each { |e| puts "#{e['type']} #{e['text']} #{e['relevance']}" }
		if article.source == "The Guardian" # Doesn't provide summaries
			a_concepts = AlchemyAPI::ConceptTagging.new.search(text: article.title)
		else
			a_concepts = AlchemyAPI::ConceptTagging.new.search(text: article.summary)
		end
		#a_concepts.each { |c| puts "#{c['text']} #{c['relevance']}" }
		keywords = a_concepts #+ a_entities
		for keyword in keywords
			if keyword['relevance'].to_f > MIN_RELEVANCE
				tags << keyword['text']
			end
		end
		add_tags_from_array(tags)
	end

	def add_tags_from_array(tag_array)
		for tag in tag_array
			self.tag_list.add(tag)
		end
	end
end
