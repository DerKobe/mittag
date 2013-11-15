@Vendors = new Meteor.Collection('vendors')

Meteor.publish 'vendors', ->
  return Vendors.find({})

Vendors.allow(
  insert: (userId, message)->
    true
)

Meteor.methods(
  nominateVendor: (vendorId)->
    Vendors.update vendorId, $set: { nominated: true }
  selectVendor: (vendorId)->
    Vendors.update vendorId, $addToSet: { participants: Meteor.user() }
  deselectVendor: (vendorId)->
    Vendors.update vendorId, $pull: { participants: { _id: Meteor.userId() } }
)