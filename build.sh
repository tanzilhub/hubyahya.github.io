set -e

DEPLOY_REPO="https://${DEBEZIUM}@github.com/hubyahya/hubyahya.github.io.git"

function main {
	clean
	get_current_site
	build_site
	deploy
}

function clean { 
	echo "cleaning _site folder"
	if [ -d "_site" ]; then rm -Rf _site; fi 
}

function get_current_site { 
	echo "getting latest site"
	git clone --depth 1 $DEPLOY_REPO _site 
}

function build_site { 
	echo "building site"
	bundle exec jekyll build --trace
}

function deploy {
	echo "deploying changes"

	if [ -z "$TRAVIS_PULL_REQUEST" ]; then
	    echo "except don't publish site for pull requests"
	    exit 0
	fi  

	if [ "$TRAVIS_BRANCH" != "website-migration" ]; then
	    echo "except we should only publish the website-migration branch. stopping here"
	    exit 0
	fi

	cd _site
	git config --global user.name "hubyahya"
    git config --global user.email shamshad.alam2@gmail.com
	git add -A
	git status
	git commit -m "Lastest site built on successful travis build $TRAVIS_BUILD_NUMBER auto-pushed to github"
	git push $DEPLOY_REPO HEAD:master --force
}

main