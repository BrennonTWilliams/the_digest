class AdvancedTaggingJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
  	puts "*"*100
    puts "RUNNING BACKGROUND JOB"
  end
end
