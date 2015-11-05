class Repository < ActiveRecord::Base
  include ActiveDateChecker
  include Breadcrumb
  include CascadedEventable
  include CascadedRedFlaggable
  include MedusaAutoHtml
  include EmailPersonAssociator

  email_person_association(:contact)
  belongs_to :institution
  has_many :collections, dependent: :destroy
  has_many :assessments, as: :assessable, dependent: :destroy

  LDAP_DOMAINS = %w(uofi uiuc)

  validates_uniqueness_of :title
  validates_presence_of :title
  validates_presence_of :institution_id
  validate :check_active_dates
  validates_inclusion_of :ldap_admin_domain, in: LDAP_DOMAINS, allow_blank: true

  standard_auto_html(:notes)

  breadcrumbs parent: nil, label: :title
  cascades_events parent: nil
  cascades_red_flags parent: nil

  def total_size
    self.collections.collect { |c| c.total_size }.sum
  end

  def total_files
    self.collections.collect { |c| c.total_files }.sum
  end

  #TODO - this will probably not be correct any more when we have more than one institution
  def self.aggregate_size
    BitLevelFileGroup.aggregate_size
  end

  def recursive_assessments
    self.assessments + self.collections.collect { |collection| collection.recursive_assessments }.flatten
  end

  def manager?(user)
    ApplicationController.is_member_of?(self.ldap_admin_group, user, self.ldap_admin_domain)
  end

  def repository
    self
  end

  include Rails.application.routes.url_helpers

  def rdf_uri
    RDF::URI('http://localhost:3000' + polymorphic_path(self))
  end

  def rdf_medusa_property_uri(name)
    RDF::URI("https://medusa.library.illinois.edu/terms/#{name}")
  end

  def rdf_node(name, value)
    [self.rdf_uri, rdf_medusa_property_uri(name), value]
  end

  def to_rdf
    RDF::Graph.new.tap do |g|
      g << rdf_node(:id, self.id)
      g << rdf_node(:title, self.title)
    end
  end

  def store_rdf
    FusekiInteractor.instance.insert(self.to_rdf)
  end

end
