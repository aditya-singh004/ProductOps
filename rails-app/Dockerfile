FROM ruby:3.3.4

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends build-essential libpq-dev nodejs curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY Gemfile ./
RUN bundle install
COPY . .
RUN rm -f Gemfile.lock && bundle install

EXPOSE 3000
CMD ["bash", "-lc", "rm -f tmp/pids/server.pid && bundle exec rails server -b 0.0.0.0"]
