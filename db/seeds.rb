# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

## Create a dummy user
user = User.create!(first_name: "Bren", last_name: "Will", password: "password", password_confirmation:"password",
	email: "brennonw@gmail.com", bio: "Just a guy",
	username: 'bren')