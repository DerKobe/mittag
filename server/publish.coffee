@Vendors = new Meteor.Collection('vendors')
@Messages = new Meteor.Collection('messages')

Meteor.publish 'vendors', ->
  return Vendors.find({})

Meteor.publish 'messages', ->
  return Messages.find({}, { limit: 100 })

Meteor.methods(
  getEnvironment: ->
    if(process.env.ROOT_URL == "http://localhost:3000/")
      "development"
    else
      "production"

  nominateVendor: (vendorId)->
    console.log "nominateVendor #{vendorId}"
    Vendors.update vendorId, $set: { nominated: true}
)

Messages.allow(
  insert: (userId, message)->
    true
)