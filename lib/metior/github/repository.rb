# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'octokit'

require 'metior/github'
require 'metior/github/commit'
require 'metior/repository'

module Metior

  module GitHub

    # Represents a GitHub source code repository
    #
    # @author Sebastian Staudt
    class Repository < Metior::Repository

      include Metior::GitHub

      # @return [String] The project name of the repository
      attr_reader :project

      # @return [String] The GitHub username of the repository's owner
      attr_reader :user

      # Creates a new GitHub repository based on the given user and project
      # names
      #
      # @param [String] user The GitHub username of repository's owner
      # @param [String] project The name of the project
      def initialize(user, project)
        super "#{user}/#{project}"

        @project = project
        @user    = user
      end

      private

      # This method uses Octokit to load all commits from the given commit
      # range
      #
      # If you want to compare a branch with another (i.e. if you supply a
      # range of commits), it needs two calls to the GitHub API to get all
      # commits of each branch. The comparison is done in the code, so the
      # limits (see below) will be effectively cut in half.
      #
      # @note GitHub API is currently limited to 60 calls a minute, so you
      #       won't be able to query branches with more than 2100 commits
      #       (35 commits per call).
      # @param [String, Range] range The range of commits for which the commits
      #        should be loaded. This may be given as a string
      #        (`'master..development'`), a range (`'master'..'development'`)
      #        or as a single ref (`'master'`). A single ref name means all
      #        commits reachable from that ref.
      # @return [Array<Commit>] All commits in the given commit range
      # @see #load_branch_commits
      def load_commits(range)
        commits      = load_branch_commits(range.last, range)
        base_commits = load_branch_commits(range.first, range).map! do |commit|
          commit.id
        end
        commits.reject { |commit| base_commits.include? commit.id }
      end

      # This method uses Octokit to load all commits from the given branch
      #
      # Because of GitHub API limitations, the commits have to be loaded in
      # batches.
      #
      # @note GitHub API is currently limited to 60 calls a minute, so you
      #       won't be able to query branches with more than 2100 commits
      #       (35 commits per call).
      # @param [String] branch The branch to load commits from
      # @param [String, Range] range The range of commits to which the loaded
      #        commits should be assigned
      # @return [Array<Commit>] All commits from the given branch
      # @see Octokit::Commits#commits
      def load_branch_commits(branch, range)
        commits = []
        page = 1
        begin
          begin
            commits += Octokit.commits(@path, range, :page => page)
            page += 1
          end while true
        rescue Octokit::NotFound
        end
        commits
      end

    end

  end

end