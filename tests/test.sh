#!/bin/bash -eu

t=`dirname ${BASH_SOURCE}`
export PATH=`realpath ${t}/..`:$PATH

DIR=`mktemp -d /tmp/gitbottle-testXXXXX`
cd ${DIR}

echo ${DIR}

mkdir a
cd a
git init
echo 'bla1' > file
git add file
echo 'bla2' > file-non-conflicting
git add file-non-conflicting
echo 'bla3' > file-non-conflicting-2
git add file-non-conflicting-2
echo 'bla3b' > file-non-conflicting-3
git add file-non-conflicting-3
echo 'bla4' > file-will-be-removed-up
git add file-will-be-removed-up
echo 'bla5' > file-will-be-removed-down
git add file-will-be-removed-down
git config user.email some@user.com
git config user.name "Some User"
git commit -m "First commit"

cd ..

git clone a b
cd b
git config user.email some@user.com
git config user.name "Some User"
cd ..

git clone a c
cd c
git config user.email some@user.com
git config user.name "Some User"
cd ..

cd a
echo 'foo' >> file
echo 'foox' >> file-will-be-removed-down
git rm -f file-will-be-removed-up
git commit -a -m "Change"
cd ..

cd b
echo 'foo2' >> file2
git add .
git commit -a -m "Non-conflicting change"

echo 'foo2' >> file
echo 'foox' >> file-will-be-removed-up
echo 'bla2' >> file-non-conflicting
git add file-non-conflicting
git rm -f file-will-be-removed-down
git commit -a -m "Conflicting change"

echo 'foo2' >> file3
git add .
git commit -a -m "Another Non-conflicting change"

git fetch

echo Test rebase interactive with conflicts
echo ---------------------------------------

GIT_EDITOR=true git rebase -i origin/master || true
diff -urN ../c . > /tmp/x || true

echo untracked >> untracked
echo 'bla3' >> file-non-conflicting-2
git add file-non-conflicting-2
echo 'bla3' >> file-non-conflicting-2

git-bottle
git-unbottle
# TODO: verify that we are back from the state that
# we left in git-bottle.
git rebase --abort

echo Test rebase non-interactive with conflicts
echo ---------------------------------------

GIT_EDITOR=true git rebase origin/master || true
diff -urN ../c . > /tmp/x || true

echo untracked >> untracked
echo 'bla3' >> file-non-conflicting-2
git add file-non-conflicting-2
echo 'bla3' >> file-non-conflicting-2

git-bottle
git-unbottle
# TODO: verify that we are back from the state that
# we left in git-bottle.
git rebase --abort

echo  Test handling a git merge
echo ---------------------------------------
GIT_EDITOR=true git merge origin/master || true
diff -urN ../c . > /tmp/x || true

echo untracked >> untracked
echo 'bla3' >> file-non-conflicting-2
git add file-non-conflicting-2
echo 'bla3' >> file-non-conflicting-2
echo 'bla3' >> file-non-conflicting-3

git-bottle
git-unbottle

# TODO: verify that we are back from the state that
# we left in git-bottle.
git reset --hard HEAD

cd ..

rm -rf a b c

rmdir ${DIR}
