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

    #master node for reference point
    master_node = Graph::WordCluster.find_or_create(attributes)
    #set previous node for possible mutation
    previous_node = master_node

    #return early if there are no possible mutations
    if !(split_text.length > 1)
      return true
    end


    #forward mutation of text
    #initialize the mutation of text
    mut_text = split_text
    (split_text.length).times do |mutation_index|
      mut_text = split_text[0..mutation_index].join(" ")
      logger.info "Forward Mutation: #{mut_text.to_s}"
      mut_attributes = {
        text: mut_text,
        text_length: mut_text.length,
        word_count: split_text[0..mutation_index].length
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

    #backward mutation of text
    previous_node = master_node
    mut_text = split_text
    (split_text.length).times do |mutation_index|
      mut_text = split_text[(mutation_index + 1)..-1].join(" ")
      logger.info "Backwards Mutation: #{mut_text.to_s}"
      mut_attributes = {
        text: mut_text,
        text_length: mut_text.length,
        word_count: split_text[(mutation_index + 1)..-1].length
      }
      #dont enter a blank space
      if mut_attributes[:text] == ""
        break
      end

      sub_node = Graph::WordCluster.find_or_create(mut_attributes)
      sub_node.set_attributes(mut_attributes)
      previous_node.slave_clusters << sub_node
      previous_node = sub_node
    end

  end
end
