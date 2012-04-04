class Block < ActiveRecord::Base
  
  belongs_to :case
  
  has_one :html_detail, :dependent => :destroy    
  has_one :picture, :dependent => :destroy
  has_one :video, :dependent => :destroy
  
  attr_accessor :insert_before_id
  
  before_create :initialize_weight
  after_create :adjust_weight_after_insert
  
  before_destroy :adjust_weights
  before_destroy :invalidate_report
  
  default_scope :order => 'weight'
  
  def alignment
    if self.picture
      self.picture.alignment
    elsif self.video
      self.video.alignment
    end
  end
  
  # Layout strategy - used during the Preview and PDF:
  # 
  # if element is LEFT-floated, 
  # - if it's preceded by RIGHT float, apply BR after it
  # - else render BR.clear before it
  #
  # - if element is RIGHT-floated
  # - if it's preceded by LEFT floated element, apply BR.clear AFTER it
  # - else apply BR.clear before it
  #  
  def clear
    prev_block = prev
    case alignment
    when 'left'
      (prev_block && prev_block.alignment == 'right') ? :after : :before
    when 'right'
      (prev_block && prev_block.alignment == 'left') ? :after : :before
    else
      nil
    end    
  end
    
  def floated?
    alignment == 'left' || alignment == 'right'
  end
  
  def title
    result = 'Block'
    if self.html_detail
      result = 'Text Block'
    end
    if self.picture
      result = 'Picture Block'
    end
    if self.video
      result = 'Video Block'
    end
    result
    
  end
  
  def prev
    self.case.blocks.where(:weight => self.weight - 1).first
  end
  
  def as_json(options = {})    
    
    #Rails::logger.debug("as_json: options")
    #Rails::logger.debug(options)
    
    include = []
    except = [:created_at, :updated_at, :id, :case_id]    
    result = super(:include => include, :except => except)
    
    options = {
      :for_pdf => options ? options[:for_pdf] : false,
      :except => [:id, :block_id, :updated_at, :created_at]
    }        
    
    if self.html_detail 
      result['htmlDetail'] = self.html_detail.as_json(options)
    end
    if self.video
      result['video'] = self.video.as_json(options)            
    end
    if self.picture
      result['picture'] = self.picture.as_json(options)
    end
    result
  
  end
  
  private
  
  def initialize_weight
    self.weight = self.case.blocks.maximum('weight').to_i + 1
  end
  
  def adjust_weight_after_insert
    if self.insert_before_id.to_i > 0
      block_before = self.case.blocks.find_by_id(self.insert_before_id)
      if block_before        
        new_weight = block_before.weight
        Block.connection.update(
        "UPDATE blocks SET weight = weight + 1 
         WHERE case_id = #{self.case.id} AND weight >= #{new_weight}")
        self.weight = new_weight
        save
      end
    end
  end
  
  def invalidate_report
    Report.invalidate_for_case self.case_id
  end
  
  def adjust_weights
    case_id = self.case.id.to_i
    weight  = self.weight.to_i
    Block.connection.update(
      "UPDATE blocks SET weight = weight - 1 
       WHERE case_id = #{case_id} AND weight >= #{weight}")
  end
  
end
