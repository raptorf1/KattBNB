class AddLangPrefToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :lang_pref, :string
  end
end
