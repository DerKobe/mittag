Template.vendorNomination.vendors = ->
  Vendors.find()
Template.vendorNomination.isNominated = ->
  !!@nominated_at

Template.vendorNomination.events(
  'submit .new-vendor': (e)->
    e.preventDefault()
    $input = $(e.currentTarget).find('input')
    Vendors.insert name: $input.val(), nominated_at: { $exists: true }, participants: []
    $input.val('')

)
Template.vendorNomination.events(
  'click [data-action=nominate]': ->
    Meteor.call 'nominateVendor', @_id
)