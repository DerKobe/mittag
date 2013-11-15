Meteor.startup ->
  environment = ->
    if(process.env.ROOT_URL == "http://localhost:3000/")
      "development"
    else
      "production"

  # code to run on server at startup
  if Vendors.find().count() == 0
    names = ["Pizza Bonn", "Magd und Knecht"]

    for name in names
      Vendors.insert name: name, nominated_at: null

  if environment() == 'development'
    Meteor.users.find().forEach (user)->
      Meteor.users.update(user._id, $set: { 'profile.admin': true })