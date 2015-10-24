# README #

This README would normally document whatever steps are necessary to get your application up and running.

### Usage ###
1) Run:
```
#!console

brew install redis
```

2) Run
```
#!console

bundle install
```

3) Initialize the backend server with:
```
#!console

redis-server &
```

4) Initialize the Sidekiq Worker with:
```
#!console

bundle exec sidekiq
```

5) Initialize the Rails server with:
```
#!console

rails s
```