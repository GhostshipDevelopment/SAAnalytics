require 'rdf/rdfxml'
module SenticnetHelper
  def load_rdf_to_neo4j(path)
    rdfxml_file = RDF::RDFXML::Reader.open(path)
    root_node = rdfxml_file.root.node

    #parse the subnodes. These are broken up into each individual concepts.
    root_node.children.each do |concept_node|
      #skip the blank elements
      next if concept_node.class == REXML::Text
      text = ""
      polarity = 0
      concept_node.children.each do |concept_child|
        #skip blank elements
        next if concept_child.class == REXML::Text
        next if concept_child.name == "text" && concept_child.text.blank?
        next if concept_child.text == "\n\t\t" || concept_child.text == "\n"

        #parse by node name IE: node: <my_node ....>, concept_child.name == my_node
        if    concept_child.name == "type"
          #blank
        elsif concept_child.name == "text"
          text = concept_child.text
        elsif concept_child.name == "polarity"
          polarity = concept_child.text.to_f
        end
        # worker = SenticnetDataWorker.new
        # worker.perform_async(text, polarity)
        puts "Submitting: #{text}"
        sleep(0.5)
        SenticnetDataWorker.perform_async(text, polarity)
      end
    end
    return true
  end

end
