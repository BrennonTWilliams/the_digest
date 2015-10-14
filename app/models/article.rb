require 'alchemy_api'
class Article < ActiveRecord::Base
	acts_as_taggable
	ALC_API_KEY = '468a25b29d0a2637f083c0fa0b69d42997a139e3'
	IND_API_KEY = '98cc12f49a1bad14f1452d11151b99df'
	MIN_RELEVANCE = 0.5

	def generate_tags()
		generate_title_section_tags()
		find_concepts_entities()
		#generate_indico_keywords()
		self.save
	end

	def generate_title_section_tags()
		# Generates tags from the title and section
		self.title = clean_title(title)
		if all_capitalized?(self.title)
			valid_tags = get_longest_words(self.title)
			add_tags_from_array(valid_tags)
		else
			proper_nouns = find_proper_nouns(self.title)
		end
		if proper_nouns
			add_tags_from_array(proper_nouns)
		end
		if self.section
			self.tag_list.add(self.section)
		end
	end

	def generate_indico_keywords()
		Indico.api_key = API_KEY
		puts 'Indico keywords:'
		ind_keywords = Indico.keywords article1
		ind_keywords.each { |k, v| puts "#{k} #{v}" }
		puts
		puts 'Indico tags:'
		ind_tags = Indico.text_tags article1
		ind_tags_sorted = ind_tags.sort_by { |_k, v| -1.0 * v }.first(10).to_h
		ind_tags_sorted.each { |k, v| puts "#{k} #{v}" }
	end

	def find_concepts_entities()
		# Identifies and adds concept and entity tags
		AlchemyAPI.key = ALC_API_KEY
		tags = []
		#a_entities = AlchemyAPI::EntityExtraction.new.search(text: self.summary)
		#a_entities.each { |e| puts "#{e['type']} #{e['text']} #{e['relevance']}" }
		if self.source == "The Guardian" # Doesn't provide summaries
			a_concepts = AlchemyAPI::ConceptTagging.new.search(text: self.summary)
		else
			a_concepts = AlchemyAPI::ConceptTagging.new.search(text: self.summary)
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

	def clean_title(title)
		cleaned_title = ''
		for char in title.split('')
			if char =~ /[A-Za-z\s]/ #include spaces as valid
				cleaned_title += char
			end
		end
		cleaned_title
	end

	def add_tags_from_array(tag_array)
		for tag in tag_array
			self.tag_list.add(tag)
		end
	end

	def get_longest_words(title)
		# If the title contains no proper  nouns, or all the words in
		# the title are capitalized (making proper noun identification
		# impossible), this method finds the longest words in the title for 
		# tagging, as longer words are more likely to have semantic value
		sorted_words = title.split(' ').sort_by {|word| -word.length}
		num_tags = sorted_words.length / 4 # make the top 25% longest into tags
		num_tags = num_tags.to_i
		sorted_words[0..num_tags]
	end

	def trim_punctuation(tag_array)
		valid_words = [] 
		for word in tag_array
			if not is_valid_word?(word[-1])
				valid_words << word[0..word.length-2] # Cuts the last character
			end
		end
		valid_words
	end

	def all_capitalized?(title)
		words = title.split(' ')
		num_upper = 0
		valid_total = words.length # the total number of valid words
		for word in words
			if is_capital?(word)
				num_upper += 1
			elsif is_determiner?(word)
				valid_total -= 1
			elsif not is_valid_word?(word)
				valid_total -= 1
			end
		end
		# Allow for 10% margin of error in valid word detection
		num_upper >= 0.9 * valid_total
	end

	def is_valid_word?(word)
		if word != '' and word
			if word[0] =~ /[A-Za-z]/
				true
			else
				false
			end
		else
			false
		end
	end

	def is_proper_noun?(word)
		if is_valid_word?(word)
			is_capital?(word) and not is_determiner?(word)
		else
			false
		end
	end

	def is_capital?(word)
		if is_valid_word?(word)
			word[0] == word[0].upcase and word[0] =~ /[A-Za-z]/
		else
			false
		end
	end

	def is_determiner?(word)
		if is_valid_word?(word)
			determiners = ['a', 'an', 'the', 'this', 'that',
				'these', 'those', 'is', 'her', 'his',
				'its', 'our', 'their', 'few', 'either',
				'neither', 'each', 'every', 'most',
				'some', 'any', 'enough', 'all', 'both',
				'other', 'another', 'such', 'what',
				'rather', 'quite', 'and', 'but', 'or', 'nor',
				'through', 'with', 'if', 'we', 'they', 'my', 'me']
				determiners.include?(word.downcase)
			else
				false
			end
		end

		def get_next_word(words, i)
			if words[i+1]
				next_word = words[i+1]
			else
				next_word = ''
			end
		end

		def find_proper_nouns(title)
		# This method finds proper nouns by checking each title
		# word to see if its capitalized. If the proper noun is 
		# followed by another proper noun (likely a name), this method
		# consolidates them into one string for more accurate tagging.
		# So if 'Isaac Asimov' was in an article title we'd get the
		# tag 'Isaac Asimov' instead of 'Isaac' and 'Asimov' seperately.
		words = title.split(' ')
		proper_nouns = []
		i = 0
		last_word_added = ''
		for word in words
			if is_proper_noun?(word) and word != last_word_added
				next_word = get_next_word(words, i)
				if is_proper_noun?(next_word)
					name = word + ' ' + next_word
					proper_nouns << name
					last_word_added = next_word
				else
					proper_nouns << word
					last_word_added = word
				end
			end
			i += 1
		end
		proper_nouns
	end
end
