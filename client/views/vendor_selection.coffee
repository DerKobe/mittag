Template.vendorSelection.nominatedVendors = ->
  Vendors.find(nominated: true)

Template.vendorSelection.anyVendorSelected = ->
  Session.get('selectedVendor')?

Template.vendorSelection.thisVendorSelected = ->
  @_id == Session.get('selectedVendor')?._id

Template.vendorSelection.events(
  'click [data-action=select]': ->
    Meteor.call 'selectVendor', @_id
    Session.set 'selectedVendor', @

  'click [data-action=deselect]': ->
    Meteor.call 'deselectVendor', @_id
    Session.set 'selectedVendor', null

  'click [data-action=denominate]': ->
    Vendors.update @_id, $set: { nominated: false }
)