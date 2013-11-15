Template.vendorSelection.nominatedVendors = ->
  Vendors.find(nominated: true)

Template.vendorSelection.anyVendorSelected = ->
  Session.get('selectedVendor')?

Template.vendorSelection.thisVendorSelected = ->
  @_id == Session.get('selectedVendor')?._id

Template.vendorSelection.events(
  'click [data-action=select]': ->
    Vendors.update @_id, $addToSet: { participants: Meteor.user() }
    Session.set 'selectedVendor', @

  'click [data-action=deselect]': ->
    Vendors.update @_id, $pull: { participants: { _id: Meteor.userId() } }
    Session.set 'selectedVendor', null

  'click [data-action=denominate]': ->
    Vendors.update @_id, $set: { nominated: false }
)