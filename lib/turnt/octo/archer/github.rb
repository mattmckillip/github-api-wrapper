require 'turnt/octo/archer/version'
require 'turnt/octo/archer/github'
require 'HTTParty'

class Github

  # Public: Initialize a new Github wrapper.
  #
  # api_url  - The String which will contain the base api url.
  # org_name - The String which will contain the organizations name.
  # project_name  - The String which will contain the project name.
  #
  # Returns nothing.
  def initialize(api_url, org_name, project_name)
    @api_url = api_url
    @org_name = org_name
    @project_name = project_name

    # set up common fields
    github_response('')

    if response?
      @id = @response['id']
      @name = @response['name']
      @owner = @response['owner']['login']
      @private = @response['private']
      @url = @response['url']
      @created_at = @response['created_at']
      @has_issues = @response['has_issues']
      @default_branch = @response['default_branch']
      @subscribers = @response['subscribers_count']
    end

  end

  # Internal: Call HTTParty to and store the hash in @response.
  #
  # additional_info - The String which will contain any trailing information appended to the end ot the url.
  #
  # Returns the HTTParty request in the @response hash.
  def github_response(additional_info)
    @response = HTTParty.get("#{@api_url}#{@org_name}/#{@project_name}#{additional_info}", headers:{'User-Agent' => 'test'})
  end

  # Public: Gets the id for this project.
  #
  # Returns the id for the project.
  def id
    @id
  end

  # Public: Gets the name of this project.
  #
  # Returns the name of the project.
  def name
    @name
  end

  # Public: Gets the owner of this project.
  #
  # Returns the owner of the project.
  def owner
    @owner
  end

  # Public: Checks if the project is private.
  #
  # Returns true if the project is private.
  def private?
    @private
  end

  # Public: Gets the url for this project.
  #
  # Returns the url for the project.
  def url
    @url
  end

  # Public: Gets the creation date for this project.
  #
  # Returns the creation date for the project.
  def created_at
    @created_at
  end

  # Public: Checks for open issues in the project.
  #
  # Returns true if there are any open issues.
  def issues?
    @has_issues
  end

  # Public: Gets the default branch for this project.
  #
  # Returns the default branch for the project.
  def default_branch
    @default_branch
  end

  # Public: Gets the number of subscribers for this project.
  #
  # Returns the number of subscribers for the project.
  def subscribers
    @subscribers
  end

  # Public: Gets the total number of commits in the past year.
  #
  # Returns the number of commits in the past year.
  def yearly_commits
    github_response('/stats/participation')

    if response?
      # Returns a list containing 52 indices with number of commits that week
      commits_weekly = @response['all']

      # Add up all the weeks commits to get the total commits that year
      commits_weekly = commits_weekly.inject(:+)
    end
    commits_weekly
  end

  # Public: Gets the number of subscribers for this project.
  #
  # day - The Integer number representing the day (0:sunday, 1: monday, ...).
  #
  # Returns the number of commits for the given day of the week.
  def commits_per_day_of_week(day)
    github_response('/stats/punch_card')
    if response?
      sum = 0
      # Iterate through hash, adding the 2nd index which is number of commits that day
      @response.each do |subarray|
        sum += subarray[2] if subarray[0] == day
      end
    end
    sum
  end

  # Public: Gets the number of subscribers for this project.
  #
  # hour - The Integer number representing the hour of the day (0..23).
  #
  # Returns the number of commits for a given hour of the day.
  def commits_per_hour_of_day(hour)
    github_response('/stats/punch_card')
    if response?
      sum = 0
      # Iterate through hash, adding the 2nd index which is number of commits that hour
      @response.each do |subarray|
        sum += subarray[2] if subarray[1] == hour
      end
    end
    sum
  end

  # Public: Gets the number of branches for this project.
  #
  # Returns the number of branches for the project.
  def number_of_branches
    github_response('/branches')
    return nil unless response?
    @response.length
  end

  # Public: Gets the name of the author for the latest commit.
  #
  # Returns a string containing the author name.
  def latest_committer
    github_response('/commits')

    return nil unless response?
    @response[0]['commit']['author']['name']
  end

  # Public: returns the number of weeks in the past given amount of weeks
  #
  # num_weeks - the number of weeks for the number of commits
  #
  # Returns the number of commits for the specified number of weeks
  def commits_past_weeks(num_weeks)
    github_response('/stats/participation')
    if response?
      past_weeks_commits = @response['all'].reverse![0, num_weeks]

      # Add up all the weeks commits to get the total commits in the timespan
      past_weeks_commits = past_weeks_commits.inject(:+)
    end
    past_weeks_commits
  end

  # Public: Finds the relevant information for current issues
  #
  # Returns an array of hashes containing information about the open issues
  def current_issues
    github_response('/issues')
    if response?
      issue_hash = {}
      issues = []
      @response.each do |subhash|
        issue_hash['id'] = subhash['id']
        issue_hash['title'] = subhash['title']
        issue_hash['user'] = subhash['user']['login']
        issue_hash['state'] = subhash['state']
        issue_hash['url'] = subhash['url']

        # Add isses to the array
        issues << issue_hash
      end
    end
    issues
  end

  # Public: Finds the amount of commits for each author
  #
  # Returns a hash of authors and the number of commits mad
  def commits_per_author
    github_response('/commits')
    if response?
      authors = {}
      @response.each do |subhash|
        name = subhash['commit']['author']['name']
        authors[name] = 0 unless authors.has_key? name
        authors[name] += 1
      end
    end

    authors
  end

  # Public: Finds the number of lines written in each programming language
  #
  # Returns a hash of the langauges and the number of lines
  def languages
    github_response('/languages')
    return nil unless response?
    @response
  end

  # Internal: tests if the response is good
  def response?
    if @response.is_a?(Hash) && @response['message'] == 'Not Found'
      return false
    elsif @response.nil?
      return false
    else
      return true
    end
  end

end