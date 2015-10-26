# The Digest: SWEN30006 Project 3 #

### Introduction ###

The Digest is a news aggregator service that scrapes articles from several news outlets, generates tags for each article, and serves the articles to users with relevant interests both within the application and through email.

This application is our Project 3 entry for Software Engineering 30006, The University of Melburne.

### Team ###

Brennon Williams, Washington and Lee University
Nick Batchelder, Brown University
Myles Gleeson, The University of Melbourne

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
