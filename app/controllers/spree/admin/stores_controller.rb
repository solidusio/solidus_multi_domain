module StoresControllerDecorator
  extend ActiveSupport::Concern

  included do
    prepend(InstanceMethod)
    before_action :load_payment_methods
    before_action :load_shipping_methods

    def index
      @stores = @stores.ransack({ name_or_domains_or_code_cont: params[:q] }).result if params[:q]
      @stores = @stores.where(id: params[:ids].split(',')) if params[:ids]

      respond_with(@stores) do |format|
        format.html
        format.json
      end
    end
  end

  module InstanceMethod
    private

    def load_payment_methods
      @payment_methods = Spree::PaymentMethod.all
    end

    def load_shipping_methods
      @shipping_methods = Spree::ShippingMethod.all
    end
  end
end

if SpreeMultiDomain::Engine.stores_controller_available?
  Spree::Admin::StoresController.include(StoresControllerDecorator)
else
  class Spree::Admin::StoresController < Spree::Admin::ResourceController
    include StoresControllerDecorator
  end
end
