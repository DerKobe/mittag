Template.vendorNomination.vendors = ->
  Vendors.find()

Template.vendorNomination.events(
  'submit .new-vendor': (e)->
    e.preventDefault()
    $input = $(e.currentTarget).find('input')
    Vendors.insert name: $input.val(), nominated: true, participants: []
    $input.val('')

)
Template.vendorNomination.events(
  'click [data-action=nominate]': ->
    Vendors.update @_id, $set: { nominated: true }
)