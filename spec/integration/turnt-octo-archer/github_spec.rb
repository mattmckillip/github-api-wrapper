require 'turnt/octo/archer/github'


RSpec.describe Github do
  before :each do
    @github = Github.new("http://github.cerner.com/api/v3/repos/", "OpsInfra", "ops_spork")
  end

  describe '.subscribers' do
    it 'returns subscribers' do
      expect(@github.subscribers).to eq 19
    end
  end

  describe '.yearly_commits' do
    it 'returns number of commits this year' do
      expect(@github.yearly_commits).to be > 50
    end
  end

  describe '.commits_per_day_of_week' do
    it 'returns number of commits for a given day of the week' do
      expect(@github.commits_per_day_of_week(4)).to be > 5
    end
  end

  describe '.commits_per_hour_of_day' do
    it 'returns number of commits for a certain hour in a day' do
      expect(@github.commits_per_hour_of_day(12)).to be > 5
    end
  end

  describe '.number_of_branches' do
    it 'returns number of branches for the repo' do
      expect(@github.number_of_branches).to eq 7
    end
  end


  describe '.latest_committer' do
    it 'returns name of latestcommitter ' do
      expect(@github.latest_committer).to eq "David Crowder"
    end
  end

  describe '.commits_past_weeks' do
    it 'returns muber of commits_past_weeks ' do
      expect(@github.commits_past_weeks(5)).to eq 3
    end
  end

  describe '.current_issues' do
    it 'returns information about the of current issues ' do
      expect(@github.current_issues[0]["user"]).to eq "ab8971"
    end
  end
end