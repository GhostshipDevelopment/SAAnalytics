require "#{Rails.root}/app/helpers/senticnet_helper"
include SenticnetHelper
namespace :graph_neo4j do
  desc "Load senticnet 3 word clusters to neo4j instance."
  task :load_senticnet => :environment do
    sent_helper = SenticnetHelper.load_rdf_to_neo4j "#{Rails.root}/public/senticnet3.rdf.xml"
  end


  desc "Remove all word clusters on neo4j instance."
  task :remove_wordclusters => :environment do
    Graph::WordCluster.all.delete_all
  end
end
