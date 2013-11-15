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
      Vendors.insert name: name, nominated: false

  if environment() == 'development'
    Meteor.users.find().forEach (user)->
      Meteor.users.update(user._id, $set: { 'profile.admin': true })

  VENDOR_TIMEOUT = 60*1000

  timeouts = {}

  # observe nominations without participants
  Vendors.find(nominated: true, participants: { $size: 0 }).observe(
    added: (vendor)->
      console.log "watching #{vendor.name}, will denominate in 60s unless someone participates"
      Vendors.update vendor._id, $set: { watched_at: new Date() }
      timeouts[vendor._id] = Meteor.setTimeout(->
        console.log "denominate #{vendor.name} after 60s"
        Vendors.update { _id: vendor._id, participants: { $size: 0 }}, $set: { nominated: false }
        delete timeouts[vendor._id]
      , VENDOR_TIMEOUT)

    removed: (vendor)->
      if timeout = timeouts[vendor._id]
        console.log "clear timeout for #{vendor.name}"
        Meteor.clearTimeout timeout
        delete timeouts[vendor._id]

      console.log timeouts
  )