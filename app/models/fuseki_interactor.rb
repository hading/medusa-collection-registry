require 'singleton'
class FusekiInteractor < Object
  include Singleton

  attr_accessor :url, :config

  def initialize
    self.config = YAML.load(File.join(Rails.root, 'config', 'triple_store.yml'))
    self.url = config[Rails.env]['triple_store_base_url']
  end

  def query_url
    self.url + '/query'
  end

  def update_url
    self.url + '/update'
  end

  def upload_url
    self.url + '?default'
  end

  def update_client
    SPARQL::Client.new(self.update_url)
  end

  def query_client
    SPARQL::Client.new(self.query_url)
  end

  #This replaces the whole default graph with rdf_graph and is likely
  #not what you want.
  def upload(rdf_graph)
    turtle = rdf_graph.to_ttl
    HTTParty.put(upload_url, {body: turtle,
                              headers: {'Content-Type' => 'text/turtle',
                                        'Content-Length' => turtle.length.to_s}})
  end

  def clear_all
    upload(RDF::Graph.new)
  end

  def insert(rdf_graph)
    self.update_client.insert_data(rdf_graph)
  end

  def insert_many(rdf_graph_collection)
    big_graph = rdf_graph_collection.inject(RDF::Graph.new) do |acc, g|
      acc << g
      acc
    end
    insert(big_graph)
  end

end