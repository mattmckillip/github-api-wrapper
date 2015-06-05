require 'httparty'

module TurntOctoArcher
  class GitHub

    # Public: Initialize a new GitHub wrapper.
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
    # Returns [void] the HTTParty request in the @response hash or nil if nothing was found.
    def github_response(additional_info)
      @response = HTTParty.get("#{@api_url}#{@org_name}/#{@project_name}#{additional_info}",
                               headers:{'User-Agent' => 'test'})
    end

    # Public: Gets the id for this project.
    #
    # Returns an [Integer] id for the project or nil if nothing was found.
    def id
      @id
    end

    # Public: Gets the name of this project.
    #
    # Returns the [String] name of the project or nil if nothing was found.
    def name
      @name
    end

    # Public: Gets the owner of this project.
    #
    # Returns the [String] owner of the project  or nil if nothing was found.
    def owner
      @owner
    end

    # Public: Checks if the project is private.
    #
    # Returns [Boolean] true if the project is private or nil if nothing was found.
    def private?
      @private
    end

    # Public: Gets the url for this project.
    #
    # Returns the [String] url for the project or nil if nothing was found.
    def url
      @url
    end

    # Public: Gets the creation date for this project.
    #
    # Returns the [String] creation date for the project or nil if nothing was found.
    def created_at
      @created_at
    end

    # Public: Checks for open issues in the project.
    #
    # Returns [Boolean] true if there are any open issues or nil if nothing was found.
    def issues?
      @has_issues
    end

    # Public: Gets the default branch for this project.
    #
    # Returns the [String] default branch for the project or nil if nothing was found.
    def default_branch
      @default_branch
    end

    # Public: Gets the number of subscribers for this project.
    #
    # Returns the [Integer] number of subscribers for the project or nil if nothing was found.
    def subscribers
      @subscribers
    end

    # Public: Gets the total number of commits in the past year.
    #
    # Returns the [Integer] number of commits in the past year or nil if nothing was found.
    def yearly_commits
      github_response('/stats/participation')
      commits_weekly = nil
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
    # Returns the [Integer] number of commits for the given day of the week or nil if nothing was found.
    def commits_per_day_of_week(day)
      sum = nil
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
    # Returns the [Integer] number of commits for a given hour of the day or nil if nothing was found.
    def commits_per_hour_of_day(hour)
      sum = nil
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
    # Returns the [Integer] number of branches for the project or nil if nothing was found.
    def number_of_branches
      github_response('/branches')
      return nil unless response?
      @response.length
    end

    # Public: Gets the name of the author for the latest commit.
    #
    # Returns a [String] containing the author name or nil if nothing was found.
    def latest_committer
      github_response('/commits')

      return nil unless response?
      @response[0]['commit']['author']['name']
    end

    # Public: returns the number of weeks in the past given amount of weeks
    #
    # num_weeks - the number of weeks for the number of commits
    #
    # Returns the [Integer] number of commits for the specified number of weeks or nil if nothing was found
    def commits_past_weeks(num_weeks)
      past_weeks_commits = nil
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
    # Returns an [Array] of hashes containing information about the open issues or nil if nothing was found.
    def current_issues
      issues = nil
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
    # Returns a [Hash] of authors and the number of commits made or nil if nothing was found.
    def commits_per_author
      authors = nil
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
    # Returns a [Hash] of the languages and the number of lines or nil if nothing was found.
    def languages
      github_response('/languages')
      return nil unless response?
      @response
    end

    # Internal: tests if the response is good
    #
    # Returns [Boolean] true if the @response has data inside
    def response?
      bool = true
      if @response.nil?
        bool = false
      elsif @response.is_a?(Hash) && @response['message'] == 'Not Found'
        bool = false
      end
      bool
    end
  end
end