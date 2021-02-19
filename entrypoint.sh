#!/bin/sh -l

set -e

mkdir -p /root/.ssh/
echo "${DEPLOY_KEY}" > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa
ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts

# setup deploy git account
git config --global user.name "${USER_NAME}"
git config --global user.email "${USER_EMAIL}"

echo "npm install ..." 
npm install

cd themes
if [ -d 'inside']; then
  echo "install theme dependecy .."
  cd theme/inside && npm install
  cd ..
fi
cd ..

echo "Clean folder ..."
./node_modules/hexo/bin/hexo clean

echo "Generate file ..."
./node_modules/hexo/bin/hexo generate

mv public /root/public

git stash # never commit
git checkout "${BRANCH}"

echo "copy CNAME if exists"
if [ -f "CNAME" ]; then
  mv CNAME /root/
fi

git rm -r '*'
cp -r /root/public/. .
if [ -f "/root/CNAME" ]; then
  mv /root/CNAME .
fi

rm -rf node_modules

git add --all

echo 'Start Commit'
git commit --allow-empty -m "Deploying to ${BRANCH}"

echo 'Start Push'
git remote add gitorigin "${GIT_REPO}"
git push gitorigin "${BRANCH}"

echo "Deployment succesful!"
