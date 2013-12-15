#!/bin/sh

echo "Backing up the source with a git push"
git push
if [$? -ne 0]; then
  echo "git push failed"
  exit 1
fi


echo "Running pub build..."
pub build
if [$? -ne 0]; then
  echo "Pub build failed"
  exit 1
fi


echo "Attempting to commit new build to master..."

build_rev_hash=`git rev-parse HEAD`
build_rev_branch=`git rev-parse --abbrev-ref HEAD`

git checkout master
if [$? -ne 0]; then 
  echo "Checking out master failed"
  exit 1
fi

# Clean the directory while ignoring build/ .git/ /packages and any hidden .* files
# Note that this is a potentially dangerous operation!!!! If the .git directory gets 
# clobbered, you're SOL
find . -not -empty \( -name 'build' -prune -o -name '.git' -prune \
                      -o -name '.*' -o -name 'packages' -prune \) \
       -o -prune -print0 | xargs -0 rm -r

cp -R build/* .
git add -A
git commit -m 'Revision $build_rev_hash'

echo "Publishing to origin master"
git push origin master
if [$? -ne 0]; then
  echo "Publishing failed"
  git checkout $build_rev_branch
  exit 1
fi

git checkout $build_rev_branch
echo "Deployment succeeded!"