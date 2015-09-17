module Graph
  class WordCluster
    include Neo4j::ActiveNode

    has_many :in, :master_clusters, type: :word_cluster,  model_class: WordCluster
    has_many :out, :slave_clusters, type: :word_cluster, model_class: WordCluster

    property :created_at
    property :updated_at

    property :text, type: String
    property :text_length, type: Integer
    property :word_count, type: Integer
    property :polarity, type: Float, default: 0.0
    property :average_node_polarity, type: Float, default: 0.0

    validates :length, presence: true
    validates :word_count, presence: true

    def find_or_create(attributes)
      result = self.find_by(text: attributes[:text])
      if result
        return result
      else
        result = self.create(attributes)
      end
    end
  end
end
