require 'turnt/octo/archer'
require 'turnt/octo/archer/git_hub'
require 'json'

module TurntOctoArcher
  class CLI

    # Public: Initialize a new GitHub wrapper.
    #
    # api_url       - The String which will contain the base api url.
    # org_name      - The String which will contain the organizations name.
    # project_name  - The String which will contain the project name.
    # all           - The Boolean variable which will display all information if true.
    # commits       - The Boolean variable which will display the commit information if true.
    # issues        - The Boolean variable which will display the issue information if true.
    # general       - The Boolean variable which will display the general information if true.
    #
    # Returns nothing.
    def initialize(options)
      @api_url      = options[:api_url]       == nil ? 'http://api.github.cerner.com/repos/'  : options[:api_url]
      @org_name     = options[:org_name]      == nil ? 'OpsInfra'                             : options[:org_name]
      @project_name = options[:project_name]  == nil ? 'ops_spork'                            : options[:project_name]

      # Default to false if not given any information
      @all      = options[:all]     == nil ? false : options[:all]
      @commits  = options[:commits] == nil ? false : options[:commits]
      @issues   = options[:issues]  == nil ? false : options[:issues]
      @general  = options[:general] == nil ? false : options[:general]

      # if no options are chosen, display everything
      @all = true unless @commits || @issues || @general
    end

    # Public: Run the calls to git_hub.rb and display
    #
    #
    def run
      my_github = GitHub.new(@api_url, @org_name, @project_name)
      header(my_github)
      my_hash = build_hash(my_github)
      puts hash_to_haml(my_hash)


      File.open("turnt-octo-archer.html", 'w') { |file| file.write(HashToHTML(my_hash)) }

    end

    def build_hash(my_github)
      git_hub_hash = {}
      if @all || @general
        git_hub_hash['general info'] = {}
        git_hub_hash['general info']['owner'] = my_github.owner
        git_hub_hash['general info']['id'] = my_github.id
        git_hub_hash['general info']['created'] = my_github.created_at
        git_hub_hash['general info']['languages'] = my_github.languages
        git_hub_hash['general info']['num branches'] = my_github.number_of_branches
        git_hub_hash['general info']['default branches'] = my_github.default_branch
        git_hub_hash['general info']['private'] = my_github.private?
        git_hub_hash['general info']['num subscribers'] = my_github.subscribers
      end

      if @all || @issues
        git_hub_hash['issues'] = {}
        git_hub_hash['issues']['issues?'] = my_github.issues?
        git_hub_hash['issues']['open issues'] = my_github.current_issues
      end

      if @all || @commits
        git_hub_hash['commits'] = {}
        git_hub_hash['commits']['commits past year'] = my_github.yearly_commits
        git_hub_hash['commits']['commits per author'] = my_github.commits_per_author
        git_hub_hash['commits']['commits per day'] = my_github.yearly_commits

        week_arr = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']

        git_hub_hash['commits']['commits per day'] = {}
        0.upto(6) do |i|
          git_hub_hash['commits']['commits per day'][week_arr[i].to_s] = my_github.commits_per_day_of_week(i)
        end

        git_hub_hash['commits']['commits per hour'] = {}
        0.upto(23) do |i|
          git_hub_hash['commits']['commits per hour'][i.to_s] = my_github.commits_per_hour_of_day(i)
        end
      end
      git_hub_hash
    end

    INDENT = '  ' # use 2 spaces for indentation

    def hash_to_haml(hash, level=0)
      result = [ "#{INDENT * level}" ]
      hash.each do |key,value|
        result << "#{INDENT * (level + 0)} #{key.split.map(&:capitalize)*' '}: #{value}" unless value.is_a?(Hash)
        result << "#{INDENT * (level + 0)} #{key.split.map(&:capitalize)*' '}" if value.is_a?(Hash)
        result << hash_to_haml(value, level + 2) if value.is_a?(Hash)
      end
      result.join("")
      result << "\n"
    end

    def header(my_github)
      my_string = "
                   _                    _                   _                             _
                  | |_ _   _ _ __ _ __ | |_       ___   ___| |_ ___         __ _ _ __ ___| |__   ___ _ __
                  | __| | | | '__| '_ \\| __|____ / _ \\ / __| __/ _ \\ _____ / _` | '__/ __| '_ \\ / _ \\ '__|
                  | |_| |_| | |  | | | | ||_____| (_) | (__| || (_) |_____| (_| | | | (__| | | |  __/ |
                   \\__|\\__,_|_|  |_| |_|\\__|     \\___/ \\___|\\__\\___/       \\__,_|_|  \\___|_| |_|\\___|_|"


      my_string << "\n\n\t\t\t\t  You are viewing information about #{my_github.url}"
      puts my_string
    end

    def HashToHTML(hash, opts = {})
      return if !hash.is_a?(Hash)

      indent_level = opts.fetch(:indent_level) { 0 }

      out = " " * indent_level + "<ul>\n"

      hash.each do |key, value|
        out += " " * (indent_level + 2) + "<li><strong>#{key}:</strong>"

        if value.is_a?(Hash)
          out += "\n" + HashToHTML(value, :indent_level => indent_level + 2) + " " * (indent_level + 2) + "</li>\n"
        else
          out += " <span>#{value}</span></li>\n"
        end
      end

      out += " " * indent_level + "</ul>\n"
    end

  end
end
