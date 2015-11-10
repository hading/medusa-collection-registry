require 'active_support/concern'

module TripleStorable
  extend ActiveSupport::Concern
  include Rails.application.routes.url_helpers

  included do
    class_attribute :predicate_method_hash, :owner_associations, :config
    self.config = YAML.load_file(File.join(Rails.root, 'config', 'triple_store.yml'))
    rdf_fields {}
    rdf_owners
    delegate :medusa_base_url, :medusa_rdf_prefix, to: :class
  end

  module ClassMethods
    def rdf_fields(*args)
      hash = args.extract_options!
      args.each {|arg| hash[arg] = arg}
      self.predicate_method_hash = hash
    end

    def rdf_owners(*associations)
      self.owner_associations = associations
    end

    def store_all_rdf
      self.find_in_batches do |batch|
        graphs = batch.collect {|model| model.to_rdf}
        FusekiInteractor.instance.insert_many(graphs)
      end
    end

    def medusa_base_url
      @medusa_base_url ||= self.config[Rails.env]['medusa_base_url']
    end

    def medusa_rdf_prefix
      @medusa_rdf_prefix ||= self.config[Rails.env]['medusa_rdf_prefix']
    end

  end

  def rdf_uri(model = nil)
    model ||= self
    RDF::URI(medusa_base_url + polymorphic_path(model))
  end

  def rdf_medusa_property_uri(name)
    RDF::URI("#{medusa_rdf_prefix}#{name}")
  end

  def rdf_node(name, value)
    [self.rdf_uri, rdf_medusa_property_uri(name), value]
  end

  def to_rdf
    RDF::Graph.new.tap do |g|
      g << rdf_node(:medusa_class, self.class.to_s)
      g << rdf_node(:medusa_id, self.id)
      g << rdf_node(:uuid, self.uuid) if self.respond_to?(:uuid)
      self.class.predicate_method_hash.each do |predicate, method|
        values = self.send(method)
        Array.wrap(values).each do |value|
          g << rdf_node(predicate, value) if value.present?
        end
      end
      self.class.owner_associations.each do |association|
        owner = self.send(association)
        g << rdf_node(:belongs_to, rdf_uri(owner)) if owner.present?
      end
    end
  end

  def store_rdf
    FusekiInteractor.instance.insert(self.to_rdf)
  end

  #TODO make this remove all triples with this subject and a medusa
  #predicate, or with predicates stored via store_rdf. Not sure exactly
  #how that should work yet. Something like
  # DELETE
  # ?sub <medusa_class> my-class
  # ?sub <medusa_id> my-id
  # ?sub <owned_pred_1> ?obj_1
  # ...
  # ?sub <owned_pred_n> ?obj_n
  # I don't think there is any way to match the predicates on prefix
  # so we can just delete all in the medusa namespace
  # I don't know if sparql-client supports this except via submission
  # of an explicit sparql string. However, if the above is correct
  # I don't think there are any gotchas in constructing that string.
  # An alternate way of doing this, probably not desirable but possible,
  # would be to store the rdf graph outside of the triplestore when
  # it is uploaded. Then when doing an update use it to do a delete/insert
  # along with the new graph (which would then be serialized for the
  # next update). The space consumption wouldn't be terrible, though.
  # This would solve the problem of predicates changing, etc., make it
  # easy to recreate the db, etc.
  def remove_rdf

  end

end