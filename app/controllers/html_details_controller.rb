class HtmlDetailsController < ApplicationController
  
  before_filter :authenticate_user!
  before_filter :resolve_case, :only => [ :new, :edit, :update, :create ]
  
  respond_to :html, :json, :except => :update
  
  def new    
    block = Block.new
    block.case = @case
    @detail  = HtmlDetail.new(:block => block)    
  end
  
  def create
        
    @detail = HtmlDetail.new(params[:html_detail])
    block = Block.new(:case => @case)    
    @detail.block = block
    
    respond_to do |format|
      if (@detail.save)        
        @block = @detail.block        
        format.html { redirect_to(@case, :notice => 'New Text Block has been created') }
        format.js
      else  
        format.html { render :action => 'new' }
      end
    end        
    
  end
  
  def edit    
    @detail = @case.html_details.find_by_id(params[:id])    
    redirect_to cases_path unless @detail    
  end
  
  def update
    @detail = @case.html_details.find_by_id(params[:id])    
    redirect_to cases_path unless @detail
    
    respond_to do |format|
      if @detail.update_attributes(params[:html_detail])
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
    
    @case = current_user.cases.find_by_id(params[:case_id]) || 
      redirect_to(cases_path)      
  end
  
end
