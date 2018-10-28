FROM ruby:2.5.1
RUN mkdir nickeltrack
WORKDIR nickeltrack
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
 && apt-get install -y nodejs sendmail \
 && npm install -g surge \
 && gem install bundler
ADD .build/context.tar.gz ./
RUN bundle install
CMD sleep 5 \
 && bin/rake db:create \
 && bin/rake db:migrate \
 || bin/rake db:migrate \
 && bin/bundle exec thor nickeltrack_tasks:harvest \
 && bundle exec thor nickeltrack_tasks:build \
 && surge --project build --domain nickeltrack.com \
 && echo "127.0.0.1 localhost localhost.localdomain $(hostname)" >> /etc/hosts
 # TODO: Send notification email.
