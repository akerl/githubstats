require 'spec_helper'

describe GithubStats do
  describe '.new' do
    it 'create a User object' do
      expect(GithubStats.new).to be_an_instance_of GithubStats::User
    end
  end

  describe GithubStats::User do
    let(:named_user) { GithubStats::User.new 'akerl' }
    let(:unnamed_user) { GithubStats::User.new }
    let(:hash_user) { GithubStats::User.new(name: 'fly', url: 'URL-FOR-%s') }

    context 'when created with a string' do
      it 'uses that string as the username' do
        expect(named_user.name).to eql 'akerl'
      end
      it 'uses the default URL' do
        expect(named_user.url).to eql GithubStats::DEFAULT_URL % 'akerl'
      end
    end
    context 'when created with no arguments' do
      it 'guesses the username based on the environment' do
        expect(unnamed_user.name).to be_an_instance_of String
      end
    end
    context 'when created with a hash' do
      it 'uses the name parameter as the username' do
        expect(hash_user.name).to eql 'fly'
      end
      it 'uses the URL from the hash' do
        expect(hash_user.url).to eql 'URL-FOR-fly'
      end
    end

    it 'does not pull data until it needs to' do
      expect(named_user.instance_variables).to_not include(:@data)
      expect(named_user.last_updated).to be_nil
      named_user.data
      expect(named_user.instance_variables).to include(:@data)
      expect(named_user.last_updated).to be_an_instance_of DateTime
    end

    it 'raises an exception if it cannot load data' do
      expect { hash_user.scores }.to raise_error RuntimeError
    end

    it 'returns a human-readable string when inspected' do
      expect(named_user.to_s).to eql 'Contributions from akerl'
      expect(named_user.inspect).to eql 'Contributions from akerl'
    end

    it 'proxies requests for Data methods' do
      expect(named_user.scores).to be_an_instance_of Array
    end

    it 'truthfully handles respond_to? queries' do
      expect(named_user.respond_to? :to_s).to be_true
      expect(named_user.respond_to? :today).to be_true
      expect(named_user.respond_to? :abcd).to be_false
    end
  end
end
