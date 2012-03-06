class BlocksController < ApplicationController

  before_filter :authenticate_user!
  before_filter :resolve_block
  
  def destroy
    
    c = @block.case  
    @block.destroy
    @blocks_count = c.blocks.count
    respond_to do |format|
      format.html { redirect_to(c, :notice => 'The block was successfully deleted') }
      format.js
    end
    
  end
  
  private
  
  def resolve_block
    @block = current_user.blocks.find_by_id(params[:id]) || 
      redirect_to(cases_path)
  end
  
end
