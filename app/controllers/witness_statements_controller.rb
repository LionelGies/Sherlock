class WitnessStatementsController < ApplicationController
  
  before_filter :authenticate_user!
  before_filter :authorize_pi!
  
  before_filter :resolve_case
  
  respond_to :html, :json, :except => :update
  
  def create
        
    @detail = BlockTypes::WitnessStatement.new(params[:witness_statement])
    block = Block.new(:case => @case)    
    
    @insert_before_id = params[:insert_before_id].to_i
    block.insert_before_id = @insert_before_id
    @detail.block = block    
    
    respond_to do |format|
      if (@detail.save)        
        @block = @detail.block
        logger.debug("Witness statement saved")
        format.html { redirect_to(@case, :notice => 'Witness Statement has been created') }
        format.js
      else  
        logger.debug("Witness statement not saved")
        format.html { render :action => 'new' }
      end
    end        
    
  end
    
  def update
    @detail = @case.witness_statements.find_by_id(params[:id])    
    redirect_to cases_path unless @detail
    
    respond_to do |format|
      if @detail.update_attributes(params[:witness_statement])
        @block = @detail.block
        format.html { redirect_to(@case, :notice => 'The block has been successfully updated') }
        format.js
      else
        format.html { render :action => 'edit' }
      end
    end
    
  end
  
  private
  
  def resolve_case
    resolve_case_using_param(:case_id)    
  end
  
end
