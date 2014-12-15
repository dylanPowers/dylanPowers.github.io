#!/bin/sh

echo "\nBacking up the source with a git push"
git push
if [ $? -ne 0 ]; then
  echo "\n\ngit push failed"
  exit 1
fi


echo "\nRunning pub build..."
pub build
if [ $? -ne 0 ]; then
  echo "\n\nPub build failed"
  exit 1
fi


echo "\nAttempting to commit new build into master..."

build_rev_hash=`git rev-parse HEAD`
build_rev_branch=`git rev-parse --abbrev-ref HEAD`

git checkout master
if [ $? -ne 0 ]; then 
  echo "\n\nChecking out master failed"
  exit 1
fi

# Clean the directory while ignoring build/ .git/ and any other hidden .* files/directories
# Note that this is a potentially dangerous operation!!!! If the .git directory gets 
# clobbered, you're SOL
find . -maxdepth 1 -not -empty \( -name 'build' -prune -o -name '.git' -prune \
                                  -o -wholename './.*' -prune \) \
                   -o -print0 | xargs -0 rm -r

# Put the deployable files into place
cp -R build/web/* .
git checkout $build_rev_hash -- CNAME

git add -A
git commit -m "Autobuild at revision $build_rev_hash"

echo "\nPublishing to origin master"
git push origin master
if [ $? -ne 0 ]; then
  echo "\n\nPublishing failed"
  git checkout $build_rev_branch
  pub get
  exit 1
fi

git checkout $build_rev_branch
pub get
echo "\nDeployment succeeded!"