class RecursionsController < ApplicationController
  before_filter :authenticate_customer!

  # GET /recursions
  def index
    @recursions = Recursion.where(customer: current_customer).includes(:item).all
  end

  # DELETE /recursions/:id
  def destroy
    recursion = Recursion.where(customer: current_customer).find(params[:id])
    recursion.destroy
    respond_to do |format|
      format.html { redirect_to recursions_url }
    end
  end
end
