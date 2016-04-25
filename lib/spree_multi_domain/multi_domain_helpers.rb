module SpreeMultiDomain
  module MultiDomainHelpers
    extend ActiveSupport::Concern

    include Spree::Core::ControllerHelpers::Common #layout :get_layout
    include Spree::Core::ControllerHelpers::Store #current_store

    included do
      helper 'spree/products'
      helper 'spree/taxons'

      before_filter :add_current_store_id_to_params
      helper_method :current_store
      helper_method :current_tracker
    end

    def current_tracker
      @current_tracker ||= Spree::Tracker.current(store_key)
    end

    def get_taxonomies
      @taxonomies ||= current_store.present? ? Spree::Taxonomy.where(["store_id = ?", current_store.id]) : Spree::Taxonomy
      @taxonomies = @taxonomies.includes(:root => :children)
      @taxonomies
    end

    def add_current_store_id_to_params
      params[:current_store_id] = current_store.try(:id)
    end

    private
    def store_key
      request.headers['HTTP_SPREE_STORE'] || request.env['SERVER_NAME']
    end
  end
end
