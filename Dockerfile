FROM ruby:2.4
 
LABEL maintainer="Debezium Community"
 
ENV SITE_HOME=/site \
    CACHE_HOME=/cache \
    HOME=/home/awestruct \
    NODE_PATH=/usr/local/share/.config/yarn/global/node_modules

# clean and update sources
RUN apt-get clean && apt-get update

# Install Node.js - Required by Antora
RUN curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash - \
    && sudo apt-get install -y nodejs
    

# Install Yarn
RUN npm install -g yarn

# Install Antora framework
RUN yarn global add @antora/cli@2.3.4 @antora/site-generator-default@2.3.4 \
    && rm -rf $(yarn cache dir)/* \
    && find $(yarn global dir)/node_modules/asciidoctor.js/dist/* -maxdepth 0 -not -name node -exec rm -rf {} \; \
    && find $(yarn global dir)/node_modules/handlebars/dist/* -maxdepth 0 -not -name cjs -exec rm -rf {} \; \
    && find $(yarn global dir)/node_modules/handlebars/lib/* -maxdepth 0 -not -name index.js -exec rm -rf {} \; \
    && find $(yarn global dir)/node_modules/isomorphic-git/dist/* -maxdepth 0 -not -name for-node -exec rm -rf {} \; \
    && rm -rf $(yarn global dir)/node_modules/moment/min \
    && rm -rf $(yarn global dir)/node_modules/moment/src \
    && apt-get install -y jq \
    && rm -rf /tmp/*

RUN apt-get install git

# Install Rake and Bundler. This is the minimum needed to generate the site ...
RUN gem install rdoc -v 6.2.0
RUN gem install rake bundler
RUN gem install bundler
RUN gem install jekyll
 
WORKDIR $SITE_HOME
VOLUME [ $SITE_HOME ]
 
EXPOSE 4000
 
# Install the entry point that will be called by default ...
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
 
# And execute 'run' by default ...
CMD ["run"]