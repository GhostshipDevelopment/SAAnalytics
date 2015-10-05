class SenticnetDataWorker
  include Sidekiq::Worker
  def perform(text, polarity)
    split_text = text.split(" ")

    attributes = {
      text: text,
      text_length: text.length,
      word_count: split_text.length,
      polarity: polarity
    }

    #set previous node for possible mutation
    previous_node = Graph::WordCluster.find_or_create(attributes)

    #return early if there are no possible mutations
    if !(split_text.length > 1)
      return true
    end

    #initialize the mutation of text
    mut_text = split_text
    (split_text.length).times do |mutation_index|
      mut_text = split_text[(mutation_index + 1)..-1]
      logger.info "Mutation: #{mut_text.to_s}"
      mut_attributes = {
        text: mut_text.join(" "),
        text_length: mut_text.length,
        word_count: split_text.length - mutation_index
      }
      #dont enter a blank space
      if mut_attributes[:text] == ""
        break
      end
      #find or create the node
      sub_node = Graph::WordCluster.find_or_create(mut_attributes)

      #update the node's attributes, we dont know if we loaded it or not, so just
      #update attributes
      sub_node.set_attributes(mut_attributes)
      #associate the previous node as being the master node
      previous_node.slave_clusters << sub_node
      #make the previous node the current sub node to continue association
      previous_node = sub_node
    end

  end
end
