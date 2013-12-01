require 'spec_helper'
require 'timecop'

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
    @users = open('spec/examples/results') { |f| JSON.parse f.read }
    @users.each_key do |name|
      data = JSON.parse(open("spec/examples/#{name}.user") { |fh| fh.read })
      @users[name]['data'] = GithubStats::Data.new data
    end

    @users.each do |name, results|
      Timecop.freeze Date.parse(results['date'])
      data = results.delete('data')

      context "for #{name}" do
        describe '#to_h' do
          it 'returns the data as a hash' do
            expect(data.to_h).to be_an_instance_of Hash
          end
        end

        describe '#today' do
          it 'returns the score for today' do
            expect(data.today).to eql results['today']
          end
        end

        describe '#[]=' do
          it 'returns the score for a given day' do
            expect(data[results['date']]).to eql results['today']
          end
        end

        describe '#scores' do
          it 'returns the scores as an array' do
            expect(data.scores).to be_an_instance_of Array
            expect(data.scores.size).to be 366
          end
        end

        describe '#streaks' do
          it 'returns all the streaks for a user' do
            expect(data.streaks.size).to eql results['streaks']
          end
        end

        describe '#longest_streak' do
          it "returns the user's longest streak" do
            expect(data.longest_streak.size).to eql results['longest_streak']
          end
        end

        describe '#streak' do
          it "returns a user's current streak" do
            expect(data.streak.size).to eql results['streak']
          end
        end

        describe '#max' do
          it 'returns the highest score in the set' do
            expect(data.max.score).to eql results['max']
          end
        end

        describe '#mean' do
          it 'returns the mean score of the set' do
            expect(data.mean.round 4).to eql results['mean']
          end
        end

        describe '#std_var' do
          it 'returns the standard variance of the set' do
            expect(data.std_var.round 4).to eql results['std_var']
          end
        end

        describe '#outliers' do
          it 'returns the outliers for the distribution' do
            expect(data.outliers).to eql results['outliers']
          end
        end

        describe '#quartile_boundaries' do
          it 'returns a boundaries of the quartiles of the set' do
            expect(data.quartile_boundaries).to eql results['bounds']
          end
        end

        describe '#quartiles' do
          it 'returns the quartiles for a user' do
            expect(data.quartiles[1].size).to eql results['quartiles']
          end
        end

        describe '#quartile' do
          it 'returns which quartile a point falls into' do
            results['quartile'].each do |p, q|
              expect(data.quartile(p.to_i)).to eql q
            end
          end
        end

        describe '#pad' do
          it 'returns a padded dataset' do
            expect(data.pad.size % 7).to eql 0
          end
        end
      end
    end
  end
end
