require 'spec_helper'

describe Logo do
  
  it 'Should return a correct author_id' do    
    user = FactoryGirl.create(:user)
    logo = FactoryGirl.build(:logo, :user => user)    
    logo.author_id.should == user.id
  end
        
  it 'Should not break on invalid dimensions when height_for_display is called' do
    logo = FactoryGirl.build(:logo)
    max_height = 200
    logo.height_for_display(max_height).should == max_height  
  end
  
  context "for the uploaded file picture should" do    
    
    before do    
      helper = LogoSpecHelper.new
      @logo     = helper.upload_file('shelockdocslogo.jpg', 'image/jpeg')                
      @filepath = helper.filepath      
    end
    
    it "store the image in the original dimensions" do
      original = Dimensions.dimensions(@filepath)
      Dimensions.dimensions(@logo.full_filepath).should == original            
    end
    
    it "store width and height in the record" do
      [@logo.width, @logo.height].should == Dimensions.dimensions(@filepath)
    end
   
    it "create one file_asset" do
      @logo.file_assets.count.should == 1
    end
        
  end
  
  context "for the uploaded file in EPS format it should" do
    before do          
      helper = LogoSpecHelper.new
      @logo     = helper.upload_file('football_logo.eps', 'application/postscript')                
      @filepath = helper.filepath 
    end
    
    it "store the original eps version" do      
      File.size(@logo.orig_path).should == File.size(@filepath)
    end
    
    it "convert itself to be of type PNG" do
      @logo.content_type.should == 'image/png'
    end
    
    it "create a PNG copy as high as the original" do
      Dimensions.dimensions(@logo.full_filepath)[1].should == 350
    end
    
    it "create 2 file_asset records" do
      @logo.file_assets.count.should == 2
    end
    
    it "save original content_type in the orig file_asset" do
      @logo.orig_file_asset.content_type.should == 'application/postscript'
    end
    
    it "store the dims in the record" do
      [@logo.width, @logo.height].should == Dimensions.dimensions(@logo.full_filepath)
    end
    
    it "delete the .orig file when logo is removed" do
      orig_path = @logo.orig_path
      @logo.destroy
      File.exists?(orig_path).should be_false
    end
    
    it "delete file_assets when logo is removed" do      
      @logo.destroy
      @logo.file_assets.should be_empty            
    end
    
  end
  
  context "for the uploaded file in DOS EPS format it should" do
    before do          
      helper = LogoSpecHelper.new
      @logo     = helper.upload_file('sample_dos_eps.eps', 'application/postscript')                
      @filepath = helper.filepath 
    end        
    
    it "create a PNG copy 153 high" do
      Dimensions.dimensions(@logo.full_filepath)[1].should == 153
    end        
    
  end
  
end
  