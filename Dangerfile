# Sometimes it's a README fix, or something like that - which isn't relevant for
# including in a project's CHANGELOG for example
declared_trivial = github.pr_title.include? "#trivial"

# Do not allow PRs that are marked as a work in progress to be merged yet
fail("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 500

# Warn when the Gemfile has been updated but not the Gemfile.lock, or fail if the other way around.
gemfile_updated = !git.modified_files.grep(/Gemfile/).empty?
gemfile_lock_updated = !git.modified_files.grep(/Gemfile.lock/).empty?

if gemfile_updated && !gemfile_lock_updated
  warn("The `Gemfile` was updated, but there were no changes to the `Gemfile.lock`. Did you forget to run `bundle install` or `bundle update`?")
elsif !gemfile_updated && gemfile_lock_updated
  fail("The `Gemfile.lock` has changed, but the `Gemfile` wasn't modified. Did you modify the `Gemfile` and run a `bundle` command, but then discard changes to the `Gemfile`?")
end

# Lint files with Swiftlint
swiftlint.config_file = '.swiftlint.yml'
swiftlint.lint_files
