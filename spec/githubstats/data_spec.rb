require 'spec_helper'

describe GithubStats do
  it 'defines the Github magic constant' do
    expect(GithubStats::GITHUB_MAGIC).to be_an_instance_of Float
  end

  it 'defines a Datapoint object' do
    a = GithubStats::Datapoint.new(DateTime.now, 4)
    expect(a.date).to be_an_instance_of DateTime
    expect(a.score).to eql 4
  end

  describe GithubStats::Data do
    before(:all) do
      @users = Dir.glob('spec/examples/*.user').reduce({}) do |h, f|
        name = f[14..-6]
        h[name] = GithubStats::Data.new(JSON.parse(open(f) { |fh| fh.read }))
        h
      end
      @results = open('spec/examples/results') { |f| JSON.parse f.read }
    end

    describe '#to_h' do
      it 'returns the data as a hash' do
        @users.each_value do |v|
          expect(v.to_h).to be_an_instance_of Hash
        end
      end
    end

    describe '#today' do
      it 'returns the score for today' do
        @users.each { |k, v| expect(v.today).to eql @results[k]['today'] }
      end
    end

    describe '#streaks' do
      it 'returns all the streaks for a user' do
        @users.each do |k, v|
          expect(v.streaks.size).to eql @results[k]['streaks']
        end
      end
    end

    describe '#longest_streak' do
      it "returns the user's longest streak" do
        @users.each do |k, v|
          expect(v.longest_streak.size).to eql @results[k]['longest_streak']
        end
      end
    end

    describe '#streak' do
      it "returns a user's current streak" do
        @users.each do |k, v|
          expect(v.streak.size).to eql @results[k]['streak']
        end
      end
    end

    describe '#max' do
      it 'returns the highest score in the set' do
        @users.each { |k, v| expect(v.max.score).to eql @results[k]['max'] }
      end
    end

    describe '#mean' do
      it 'returns the mean score of the set' do
        @users.each { |k, v| expect(v.mean.round 4).to eql @results[k]['mean'] }
      end
    end

    describe '#std_var' do
      it 'returns the standard variance of the set' do
        @users.each do |k, v|
          expect(v.std_var.round 4).to eql @results[k]['std_var']
        end
      end
    end

    describe '#quartile_boundaries' do
      it 'returns a boundaries of the quartiles of the set' do
        @users.each do |k, v|
          expect(v.quartile_boundaries).to eql @results[k]['bounds']
        end
      end
    end

    describe '#quartile' do
      it 'returns which quartile a point falls into' do
        @users.each do |k, v|
          @results[k]['quartile'].each do |p, q|
            expect(v.quartile(p.to_i)).to eql q
          end
        end
      end
    end
  end
end
