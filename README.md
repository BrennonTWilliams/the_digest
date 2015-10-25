# README #

This README would normally document whatever steps are necessary to get your application up and running.

### Usage ###
1) Run:
```
#!console

brew install redis
```

2) Run:
```
#!console

bundle install
```

3) Run:
```
#!console

rake db:create
```

4) Run:
```
#!console

rake db:migrate
```

5) Initialize the backend server with:
```
#!console

redis-server &
```

6) Initialize the Sidekiq Worker with:
```
#!console

bundle exec sidekiq
```

7) Initialize the Rails server with:
```
#!console

rails s
```