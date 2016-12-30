class BindArticleToTest < ActiveRecord::Migration
  def change
    bind_static_record :tests, :article
  end
end
