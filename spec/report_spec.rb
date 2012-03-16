require 'spec_helper'

describe Report do
  
  def prepare_case
    Factory(:case, :author => Factory(:user))  
  end

  def prepare_report(c = nil)      
    Factory.build(:report, :case => c || prepare_case)    
  end
  
  it 'JSON should have correct title' do
    r = prepare_report
    decoded = ActiveSupport::JSON.decode(r.to_json)
    decoded["title"].should == r.title
  end
  
  it 'JSON should have correct output file' do
    r = prepare_report
    decoded = ActiveSupport::JSON.decode(r.to_json)    
    decoded["outputFile"].should == "#{r.reports_root}#{r.output_file}"   
  end
  
  it 'JSON should have correct number of blocks' do
    c = prepare_case    
    c.blocks << Block.new(
      :html_detail => HtmlDetail.new(:contents => 'Contents of the first HTML block'))
    
    r = prepare_report(c)
    
    decoded = ActiveSupport::JSON.decode(r.to_json)
    decoded["case"]['blocks'].count.should == 1
  end
  
  it 'JSON should have correct number of blocks' do
    
    c = prepare_case
    
    c.blocks << Block.new(
      :html_detail => HtmlDetail.new(:contents => 'Contents of the first HTML block'))
    
    c.blocks << Block.new(
      :picture =>  Picture.new(:title => 'Title of the picture', :path => 'picture1.png'))
    
    r = prepare_report(c)
        
    decoded = ActiveSupport::JSON.decode(r.to_json)
    decoded["case"]['blocks'].count.should == 2
  end
  
  it 'JSON should contain templatesRoot and template' do
    r = prepare_report
    r.template = 'template.xhtml'
    
    decoded = ActiveSupport::JSON.decode(r.to_json)
    decoded['templatesRoot'].should == "#{Rails.root}/templates/"
    decoded['template'].should == 'template.xhtml'    
  end
  
  it 'picturesRoot should be absolute path' do
    r = prepare_report
    files_path = "#{Rails.root}/#{APP_CONFIG['files_path']}"
    r.pictures_root.should == "#{files_path}#{r.case.author.id}/pictures/"
  end
  
  it 'JSON should contain picturesRoot' do    
    r = prepare_report
    r.template = 'template.xhtml'    
    decoded = ActiveSupport::JSON.decode(r.to_json)    
    decoded['picturesRoot'].should == r.pictures_root
  end
  
  it 'Picture block should return its title as a caption' do
    
    c = prepare_case    
    c.blocks << Block.new(
      :html_detail => HtmlDetail.new(:contents => 'Contents of the first HTML block'))    
    
    c.blocks << Block.new(
      :picture => Picture.new(:title => 'Title of the picture', :path => 'picture1.png'))
    
    r = prepare_report(c)
    
    decoded = ActiveSupport::JSON.decode(r.to_json)
    decoded["case"]['blocks'][1]['picture']['caption'].should == 'Title of the picture'
  end
  
  it 'Video block should return its title as a caption' do
    c = prepare_case
    
    c.blocks << Block.new(
      :html_detail => HtmlDetail.new(:contents => 'Contents of the first HTML block'))
    
    c.blocks << Block.new(
      :video => Video.new(
        :title        => 'Title of the video', 
        :path         => 'video1.mpg',
        :content_type => 'video/mpeg'
      )
    )
    
    r = prepare_report(c)
    
    decoded = ActiveSupport::JSON.decode(r.to_json)
    decoded["case"]['blocks'][1]['video']['caption'].should == 'Title of the video'
  end
  
  it 'Video block should return its dimensions' do
    c = prepare_case
    
    c.blocks << Block.new(
      :html_detail => HtmlDetail.new(:contents => 'Contents of the first HTML block'))
    
    c.blocks << Block.new(
      :video => Video.new(
        :title => 'Title of the video', 
        :path => 'video1.mpg',
        :type => 'mpeg',
        :content_type => 'video/mpeg',
        :thumbnail => 'thumbnail1.png',
        :width  => 300,
        :height => 200
      )
    )    
    
    r = prepare_report(c)
    
    decoded = ActiveSupport::JSON.decode(r.to_json)
    decoded["case"]['blocks'][1]['video']['width'].should == 300
    decoded["case"]['blocks'][1]['video']['height'].should == 200
  end
  
  it 'Video block should return MPG as the format for the report' do
    c = prepare_case
    
    c.blocks << Block.new(
      :html_detail => HtmlDetail.new(:contents => 'Contents of the first HTML block'))
    
    c.blocks << Block.new(
      :video => Video.new(
        :title => 'Title of the video', 
        :path => 'video1.avi',
        :content_type => 'video/avi',
        :thumbnail => 'thumbnail1.png',
        :width  => 300,
        :height => 200
      )
    )    
    
    r = prepare_report(c)
    
    options = {
      :for_pdf => true
    }    
    
    decoded = ActiveSupport::JSON.decode(r.to_json(options))
    
    video_block = decoded["case"]['blocks'][1]['video']
    video_block['type'].should == 'mpeg'    
    video_block['path'].should == 'video1.mpg'
        
  end
  
end

