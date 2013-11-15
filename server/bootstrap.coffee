Meteor.startup ->
  # code to run on server at startup
  if Vendors.find().count() == 0
    names = ["Pizza Bonn", "Magd und Knecht"]

    for name in names
      Vendors.insert name: name, nominated: false

  if Meteor.call('getEnvironment') == 'development'
    Meteor.users.find().forEach (user)->
      Meteor.users.update(user._id, $set: { 'profile.admin': true })

  VENDOR_TIMEOUT = 60*1000

  # observe nominations without participants
  Vendors.find(nominated: true, participants: { $size: 0 }).observe(
    added: (vendor)->
      token = Random.id()
      console.log "watching #{vendor.name} (#{token}), will denominate in 60s unless someone participates"
      Vendors.update vendor._id, $set: { watched_at: new Date(), watch_token: token }
      Meteor.setTimeout(->
        console.log "denominate #{vendor.name} (#{token}) after 60s"
        Vendors.update { _id: vendor._id, watch_token: token, participants: { $size: 0 }}, $set: { nominated: false }
      , VENDOR_TIMEOUT)
  )