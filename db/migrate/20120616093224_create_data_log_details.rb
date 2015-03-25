class CreateDataLogDetails < ActiveRecord::Migration
  def change
    create_table :data_log_details do |t|      
      t.references  :block, :null => false
      t.string      :day
      t.string      :hour
      # t.string      :location
      t.text        :contents, :null => false, :limit => 64.kilobytes + 1      
      t.timestamps      
    end    
  end   
end
