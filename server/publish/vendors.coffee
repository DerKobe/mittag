@Vendors = new Meteor.Collection('vendors')
VENDOR_TIMEOUT = 60*1000

Meteor.publish 'vendors', ->
  return Vendors.find({})

Vendors.allow(
  insert: (userId, message)->
    true
)

Meteor.methods(
  nominateVendor: (vendorId)->
    Vendors.update vendorId, $set: { nominated_at: new Date() }
  selectVendor: (vendorId)->
    Vendors.update vendorId, $addToSet: { participants: Meteor.user() }
  deselectVendor: (vendorId)->
    Vendors.update vendorId, $pull: { participants: { _id: Meteor.userId() } }
)

Meteor.startup ->
  # observe nominations without participants
  timeouts = {}
  Vendors.find(nominated_at: { $exists: true }, participants: { $size: 0 }).observe
    added: (vendor)->
      console.log "watching #{vendor.name}, will denominate in 60s unless someone participates"
      Vendors.update vendor._id, $set: { watched_at: new Date() }
      timeouts[vendor._id] = Meteor.setTimeout(->
        console.log "denominate #{vendor.name} after 60s"
        Vendors.update { _id: vendor._id, participants: { $size: 0 }}, $set: { nominated_at: null }
        delete timeouts[vendor._id]
      , VENDOR_TIMEOUT)

    removed: (vendor)->
      if timeout = timeouts[vendor._id]
        console.log "clear timeout for #{vendor.name}"
        Meteor.clearTimeout timeout
        delete timeouts[vendor._id]