load Rails.root.join('db', 'migrate', '20161229011439_bind_article_to_test.rb')

RSpec.describe BindArticleToTest, :type => :migration do
  describe '.up' do
    it 'adds a column to store a StaticRecord relation' do
      test_migrate(BindArticleToTest, '20161229011439', :down, [Test])
      expect { Test.new.article_static_record_type }.to raise_error(NoMethodError)
      test_migrate(BindArticleToTest, '20161229011439', :up, [Test])
      expect { Test.new.article_static_record_type }.not_to raise_error
    end
  end
end
