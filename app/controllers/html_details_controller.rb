class HtmlDetailsController < ApplicationController
  
  before_filter :authenticate_user!
  before_filter :resolve_case, :only => [ :new, :create ]
  
  def new
    
    block = Block.new
    block.case = @case
    @detail  = HtmlDetail.new(:block => block)    
    
  end
  
  def create
        
    @detail = HtmlDetail.new(params[:html_detail])
    block = Block.new(:case => @case)    
    @detail.block = block
    
    # TODO: initialize weight to be the maximum one
        
    respond_to do |format|
      if (@detail.save) 
        format.html { redirect_to(@case, :notice => 'HTML block has been added') }
      else  
        format.html { render :action => 'new' }
      end
    end        
    
  end
  
  private
  
  def resolve_case
    @case = current_user.cases.find_by_id(params[:case_id]) || 
      redirect_to(cases_path)      
  end
  
end
