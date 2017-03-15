bundle install
git submodule update --remote

bundle exec jazzy \
  -o ./ \
  --source-directory SymondsStudentApp/ \
  --readme SymondsStudentApp/README.md \
  --module SymondsStudentApp \
  --min-acl private \
  --theme apple \
  --github_url "https://www.github.com/geosor/SymondsStudentApp" \
  --author "Søren Mortensen, George Taylor"