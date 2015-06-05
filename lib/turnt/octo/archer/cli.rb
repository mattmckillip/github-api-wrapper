require 'turnt/octo/archer'
require 'turnt/octo/archer/git_hub'

module TurntOctoArcher
  class CLI
    def initialize(options)
      @api_url = options[:api_url] == nil ? 'http://api.github.cerner.com/repos/' : options[:api_url]
      @org_name = options[:org_name] == nil ? 'OpsInfra' : options[:org_name]
      @project_name = options[:project_name] == nil ? 'ops_spork' : options[:project_name]

      # Default to false if not given any information
      @all = options[:all] == nil ? false : options[:all]
      @commits = options[:commits] == nil ? false : options[:commits]
      @issues = options[:issues] == nil ? false : options[:issues]
      @general = options[:general] == nil ? false : options[:general]

      # if no options are chosen, display everything
      @all = true unless @commits || @issues || @general
    end

    def run
      my_github = GitHub.new(@api_url, @org_name, @project_name)
      header(my_github)
      general_info(my_github)
      issue_info(my_github)
      commit_info(my_github)
      puts @my_string

    end


    def header(my_github)
      @my_string = "
                   _                    _                   _                             _
                  | |_ _   _ _ __ _ __ | |_       ___   ___| |_ ___         __ _ _ __ ___| |__   ___ _ __
                  | __| | | | '__| '_ \\| __|____ / _ \\ / __| __/ _ \\ _____ / _` | '__/ __| '_ \\ / _ \\ '__|
                  | |_| |_| | |  | | | | ||_____| (_) | (__| || (_) |_____| (_| | | | (__| | | |  __/ |
                   \\__|\\__,_|_|  |_| |_|\\__|     \\___/ \\___|\\__\\___/       \\__,_|_|  \\___|_| |_|\\___|_|"


      @my_string << "\n\nYou are viewing information about #{my_github.url}"
    end

    def general_info(my_github)
      if @all || @general
        @my_string << "\n\nRepo Information:"
        @my_string << "\nOwner: #{my_github.owner}"
        @my_string << "\nID: #{my_github.id}"
        @my_string << "\nCreated: #{my_github.created_at}"
        @my_string << "\nLangauges:"
        my_github.languages.each{ |language, _| @my_string << " #{language}"}
        @my_string << "\nNumber of Branches: #{my_github.number_of_branches}"
        @my_string << "\nDefault Branch: #{my_github.default_branch}"
        @my_string << "\nPrivate: #{my_github.private?}"
        @my_string << "\nNumber of Subscribers#{my_github.subscribers}"
      end
    end


    def issue_info(my_github)
      if @all || @issues
        @my_string << "\n\nIssues:"
        @my_string << "\nOpen Issues: #{my_github.issues?}"
        if my_github.issues?
          my_github.current_issues.each do |subarray|
            @my_string << "\n\n  ID: #{subarray['id']}"
            @my_string << "\n  Title: #{subarray['title']}"
            @my_string << "\n  User: #{subarray['user']}"
            @my_string << "\n  State: #{subarray['state']}"
            @my_string << "\n  URL: #{subarray['url']}"
          end
        end
      end
    end

    def commit_info(my_github)
      if @all || @commits
        week_arr = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
        @my_string << "\n\nCommit Information:"
        @my_string << "\nTotal Commits in the Past 4 Weeks: #{my_github.commits_past_weeks(5)}"
        @my_string << "\nTotal Commits in the Past Year: #{my_github.yearly_commits}"
        @my_string << "\n  Commits\t  Commiter"
        my_github.commits_per_author.each { |author, num_commits| @my_string << "\n\t#{num_commits}\t\t\t#{author}"}
        @my_string << "\n\n  Commits\t  Day of the Week"
        0.upto(6) do |i|
          @my_string << "\n\t#{my_github.commits_per_day_of_week(i)}\t\t\t#{week_arr[i]}"
        end
        @my_string << "\n\n  Commits\t  Hour of the Day"
        0.upto(23) do |i|
          @my_string << "\n\t#{my_github.commits_per_hour_of_day(i)}\t\t\t#{i}"
        end
      end
    end
  end
end
