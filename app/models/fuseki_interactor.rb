require 'singleton'
class FusekiInteractor < Object
  include Singleton

  attr_accessor :url, :update_client, :query_client

  def initialize
    self.url = 'http://localhost:3030/test'
    self.query_client = SPARQL::Client.new(self.query_url)
    self.update_client = SPARQL::Client.new(self.update_url)
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

  def upload(rdf_graph)
    turtle = rdf_graph.to_ttl
    HTTParty.put(upload_url, {body: turtle,
                              headers: {'Content-Type' => 'text/turtle',
                                        'Content-Length' => turtle.length.to_s}})
  end

  def insert(rdf_graph)
    self.update_client.insert_data(rdf_graph)
  end

end