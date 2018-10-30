class CreateSysLoginAttempts < ActiveRecord::Migration
  def up
    create_table :sys_login_attempts, :force => true do |t|
      t.string :state,   limit: 15
      t.datetime :created_at
      t.string :account,   limit: 255
      t.string :ipaddr,   limit: 255
      t.text :user_agent
    end
    
    add_index "sys_login_attempts", ["account"], name: "account", using: :btree
  end
  
  def down
    drop_table :sys_login_attempts
  end
end
