class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, 
                  :remember_me, :company_name,
                  :first_name, :last_name,                  
                  :user_address_attributes
 
  has_many :authored_cases, :class_name => 'Case', :foreign_key => 'author_id' 
  has_and_belongs_to_many :viewable_cases, :join_table => 'viewers', :foreign_key => 'viewer_id', :association_foreign_key => 'case_id', :class_name => 'Case'
  
  has_many :blocks, :through => :authored_cases
  has_many :pictures, :through => :blocks
  has_many :videos, :through => :blocks
  
  has_one :letterhead, :dependent => :destroy
  has_many :logos, :dependent => :destroy
  
  has_one :user_address

  accepts_nested_attributes_for :user_address
  
  def find_case_by_id(case_id)
    authored_cases.find_by_id(case_id) || viewable_cases.find_by_id(case_id)
  end
  
  def init_address
    self.user_address = UserAddress.new(
      :user     => self,
      :country  => :US
    )
  end
  
  def cases
    (authored_cases + viewable_cases).uniq
  end
    
  def invited?
    ! self.invitation_token.blank?  
  end
  
  #
  # PI's are uses who haven't been invited
  #
  def pi?
    invitation_accepted_at.blank? && (!invited?)
  end

  def can_view?( object )
    case object
    when Case
      object.viewers.include?( self ) || object.author == self
    else
      false
    end
  end 
      
  
end

