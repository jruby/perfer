module Perfer
  module Git
    class << self
      def git(command)
        output = `git #{command}`
        output.chomp!
        return nil if output.empty?
        return false if $?.exitstatus != 0
        output
      end

      def repository?
        git 'rev-parse --git-dir 2>/dev/null'
      end

      def current_branch
        branch = git 'symbolic-ref --quiet HEAD'
        branch = branch[/[^\/]+$/] if branch
        branch
      end

      def current_commit
        git 'rev-parse --quiet --verify HEAD'
      end

      def working_directory_clean?
        git('status --porcelain --untracked-files=no') == nil
      end

      def goto_commit(commit)
        raise Error, Errors::WORKING_DIR_DIRTY unless working_directory_clean?
        git "reset --quiet --hard #{commit}"
      end
    end
  end
end
