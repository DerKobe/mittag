Vendors = new Meteor.Collection("vendors");

if Meteor.isClient
  Template.vendorSelection.nominatedVendors = ->
    Vendors.find({nominated: true})

  Template.vendorSelection.user = -> Meteor.user()

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
  )



  Template.vendorNomination.vendors = ->
    Vendors.find()

  Template.vendorNomination.events(
    'submit .new-vendor': (e)->
      e.preventDefault()
      Vendors.insert name: $(e.currentTarget).find('input').val(), nominated: true

  )
  Template.vendorNomination.events(
    'click [data-action=nominate]': ->
      Vendors.update @_id, $set: { nominated: true }
  )

  Template.userInfo.onlineUsers = ->
    Meteor.users.find("profile.online": true)

  jQuery ->
    $(document).foundation();

if Meteor.isServer
  Meteor.startup ->
    # code to run on server at startup
    if Vendors.find().count() == 0
      names = ["Pizza Bonn", "Magd und Knecht"]

      for name in names
        Vendors.insert name: name, nominated: false

  Meteor.methods(
    getEnvironment: 
      if(process.env.ROOT_URL == "http://localhost:3000")
        "development"
      else
        "staging"
  )
