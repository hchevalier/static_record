require 'spec_helper'
require 'rails_helper'

RSpec.describe StaticRecord::Relation, :type => :model do

  it 'returns a StaticRecord::Relation while used method allows chaining' do
    expect(Article.where(author: 'The author')).to be_a(StaticRecord::Relation)
    expect(Article.find_by(author: 'The author')).not_to be_a(StaticRecord::Relation)
  end

  context '.all' do
    it 'returns all results' do
      expect(Article.all.count).to eql(5)
      expect(Article.see_sql_of.all).to eql("SELECT * FROM articles")
    end
  end

  context '.order' do
    context 'with a symbol' do
      it 'returns results ordered' do
        expected = [ArticleFive, ArticleFour, ArticleOne, ArticleThree, ArticleTwo]
        expect(Article.order(:name).all.map(&:class)).to eql(expected)
        expect(Article.order(:name).to_sql).to eql("SELECT * FROM articles ORDER BY articles.name ASC")
      end
    end

    context 'with a string' do
      it 'returns results ordered' do
        expected = [ArticleTwo, ArticleThree, ArticleOne, ArticleFour, ArticleFive]
        expect(Article.order("name DESC").all.map(&:class)).to eql(expected)
        expect(Article.order("name DESC").to_sql).to eql("SELECT * FROM articles ORDER BY name DESC")
      end
    end

    context 'with a hash' do
      it 'returns results ordered with one key' do
        expected = [ArticleFive, ArticleFour, ArticleOne, ArticleThree, ArticleTwo]
        expect(Article.order(name: :asc).all.map(&:class)).to eql(expected)
        expect(Article.order(name: :asc).to_sql).to eql("SELECT * FROM articles ORDER BY articles.name ASC")
      end

      it 'returns results ordered with serveral keys' do
        expected = [ArticleThree, ArticleOne, ArticleTwo, ArticleFour, ArticleFive]
        expect(Article.order(rank: :asc, name: :desc).all.map(&:class)).to eql(expected)
        expect(Article.order(rank: :asc, name: :desc).to_sql).to eql("SELECT * FROM articles ORDER BY articles.rank ASC, articles.name DESC")
      end
    end

    context 'with an array' do
      it 'returns results ordered with one key' do
        expected = [ArticleFive, ArticleFour, ArticleOne, ArticleThree, ArticleTwo]
        expect(Article.order([:name]).all.map(&:class)).to eql(expected)
        expect(Article.order([:name]).to_sql).to eql("SELECT * FROM articles ORDER BY articles.name ASC")
      end

      it 'returns results ordered with several keys' do
        expected = [ArticleThree, ArticleOne, ArticleFive, ArticleFour, ArticleTwo]
        expect(Article.order([:rank, :name]).all.map(&:class)).to eql(expected)
        expect(Article.order([:rank, :name]).to_sql).to eql("SELECT * FROM articles ORDER BY articles.rank ASC, articles.name ASC")
      end
    end
  end

  context '.first' do
    context 'without parameter' do
      it 'returns first record ordered by primary key' do
        expect(Article.first.class).to eql(ArticleFive)
        expect(Article.see_sql_of.first).to eql("SELECT * FROM articles ORDER BY articles.name ASC LIMIT 1")
      end
    end

    context 'with a parameter' do
      it 'orders records by primary key and returns up to specified number of records from the beginning' do
        expect(Article.first(2).map(&:class)).to eql([ArticleFive, ArticleFour])
        expect(Article.see_sql_of.first(2)).to eql("SELECT * FROM articles ORDER BY articles.name ASC LIMIT 2")
      end
    end
  end

  #TODO: implement .first!

  context '.last' do
    context 'without parameter' do
      it 'returns last record ordered by primary key' do
        expect(Article.last.class).to eql(ArticleTwo)
        expect(Article.see_sql_of.last).to eql("SELECT * FROM articles ORDER BY articles.name DESC LIMIT 1")
      end

      it 'returns use default sort when no primary key has been defined' do
        expect(Role.last.class).to eql(RoleTwo)
        expect(Role.see_sql_of.last).to eql("SELECT * FROM roles LIMIT 1 OFFSET #{Role.all.count - 1}")
      end
    end

    context 'with a parameter' do
      it 'orders records by primary key and returns up to specified number of records from the end' do
        expect(Article.last(2).map(&:class)).to eql([ArticleThree, ArticleTwo])
        expect(Article.see_sql_of.last(2)).to eql("SELECT * FROM articles ORDER BY articles.name DESC LIMIT 2")
      end

      it 'returns up to specified number of records from the end when no primary key is set' do
        expect(Role.last(2).map(&:class)).to eql([RoleOne, RoleTwo])
        expect(Role.see_sql_of.last(2)).to eql("SELECT * FROM roles LIMIT 2 OFFSET #{Role.all.count - 2}")
      end
    end
  end

  context '.limit' do
    it 'returns up to specified number of records' do
      expect(Article.limit(2).all.map(&:class)).to eql([ArticleFive, ArticleFour])
      expect(Article.limit(2).to_sql).to eql("SELECT * FROM articles LIMIT 2")
    end
  end

  context '.limit.offset' do
    it 'returns up to specified number of records with specified offset' do
      expect(Article.limit(2).offset(1).all.map(&:class)).to eql([ArticleFour, ArticleOne])
      expect(Article.limit(2).offset(1).to_sql).to eql("SELECT * FROM articles LIMIT 2 OFFSET 1")
    end
  end

  #TODO: implement .last!

  context '.count' do
    it 'returns results count using SQL SELECT COUNT()' do
      expect(Article.where(author: 'The author').count).to eql(2)
      expect(Article.where(author: 'The author').see_sql_of.count).to eql("SELECT COUNT(*) FROM articles WHERE author = 'The author'")
    end
  end

  context '.where' do
    it 'returns an empty array when no result' do
      expect(Article.where(author: 'Inexisting author')).to be_empty
    end

    it 'is possible to chain where clauses' do
      request = Article.where(author: 'The author').where(name: 'Article One')
      expect(request.last.class.name).to eql(ArticleOne.name)
      expect(request.to_sql).to eql("SELECT * FROM articles WHERE author = 'The author' AND name = 'Article One'")
    end

    it 'accepts array of values' do
      expect(Article.where(name: ['Article One', 'Article Two']).to_a.size).to eql(2)
      expect(Article.where(name: ['Article One', 'Article Two']).to_sql).to eql("SELECT * FROM articles WHERE name IN (\"Article One\",\"Article Two\")")
    end

    it 'accepts strings' do
      expect(Article.where("name = 'Article Two'").first.class).to eql(ArticleTwo)
      expect(Article.where("name = 'Article Two'").to_sql).to eql("SELECT * FROM articles WHERE name = 'Article Two'")
    end

    it 'accepts strings followed by an anonymous parameters' do
      expect(Article.where("name = ?", 'Article Two').first.class).to eql(ArticleTwo)
      expect(Article.where("name = ?", 'Article Two').to_sql).to eql("SELECT * FROM articles WHERE name = \"Article Two\"")
    end

    it 'accepts strings followed by several anonymous parameters' do
      expect(Article.where("name = ? AND author = ?", 'Article Two', 'The author').first.class).to eql(ArticleTwo)
      expect(Article.where("name = ? AND author = ?", 'Article Two', 'The author').to_sql).to eql("SELECT * FROM articles WHERE name = \"Article Two\" AND author = \"The author\"")
    end

    it 'accepts strings followed by a hash of named parameters' do
      expect(Article.where("name = :name AND author = :author", {name: 'Article Two', author: 'The author'}).first.class).to eql(ArticleTwo)
      expect(Article.where("name = :name AND author = :author", {name: 'Article Two', author: 'The author'}).to_sql).to eql("SELECT * FROM articles WHERE name = \"Article Two\" AND author = \"The author\"")
    end
  end

  context '.where.not' do
    it 'uses SQL != operator' do
    end

    it 'is possible to chain where and where.not clauses' do
      request = Article.where(author: 'The author').where.not(name: 'Article Two')
      expect(request.last.class.name).to eql(ArticleOne.name)
      expect(request.to_sql).to eql("SELECT * FROM articles WHERE author = 'The author' AND name != 'Article Two'")
    end

    it 'is possible to chain where.not and where.not clauses' do
      request = Article.where.not(author: ['The author', 'Me']).where.not(name: 'Article Two')
      expect(request.last.class.name).to eql(ArticleThree.name)
      expect(request.to_sql).to eql("SELECT * FROM articles WHERE author NOT IN (\"The author\",\"Me\") AND name != 'Article Two'")
    end
  end

  context '.find_by' do
    it 'limits result to 1 record' do
      expect(Article.find_by(author: 'The author').class.name).to eql(ArticleOne.name)
      expect(Article.see_sql_of.find_by(author: 'The author')).to eql("SELECT * FROM articles WHERE author = 'The author' LIMIT 1")
    end

    it 'returns nil when no result' do
      expect(Article.find_by(author: 'Inexisting author')).to be_nil
    end
  end

  #TODO: implement .find_by!

  context '.find' do
    it 'raises an error when no primary key has been set' do
      expect{ Role.find('Role One') }.to raise_error(StaticRecord::NoPrimaryKey)
    end

    it 'searches by primary key' do
      expect(Article.find('Article Two').class.name).to eql(ArticleTwo.name)
      expect(Article.see_sql_of.find('Article Two')).to eql("SELECT * FROM articles WHERE name = 'Article Two' LIMIT 1")
    end

    it 'accepts array of values' do
      expect(Article.find(['Article One', 'Article Two']).to_a.size).to eql(2)
      expect(Article.see_sql_of.find(['Article One', 'Article Two'])).to eql("SELECT * FROM articles WHERE name IN (\"Article One\",\"Article Two\")")
    end

    context 'one value' do
      it 'raises an error when no result' do
        expect{ Article.find('Inexisting Article') }.to raise_error(StaticRecord::RecordNotFound)
      end
    end

    context 'several values' do
      it 'raises an error when not all results are found' do
        expect{ Article.find(['Article One', 'Inexisting Article']) }.to raise_error(StaticRecord::RecordNotFound)
      end
    end
  end

  #TODO: implement find_each and find_in_batches

  context '.take' do
    context 'without parameter' do
      it 'returns a single record' do
        expect(Article.take.class).to be < Article
        expect(Article.see_sql_of.take).to eql("SELECT * FROM articles LIMIT 1")
      end
    end

    context 'with a parameter' do
      it 'returns up to the specified number of records' do
        expect(Article.take(2).size).to eql(2)
        expect(Article.see_sql_of.take(2)).to eql("SELECT * FROM articles LIMIT 2")
      end
    end
  end

  #TODO: implement .take!

  context '.or' do
    it 'allows to use the SQL OR' do
      expect(Article.where(author: 'Inexisting author').or.where(author: 'The author').size).to eql(2)
      expect(Article.where(author: 'Inexisting author').or.where(author: 'The author').to_sql).to eql("SELECT * FROM articles WHERE author = 'Inexisting author' OR author = 'The author'")
    end
  end
end
