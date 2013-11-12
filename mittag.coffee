Vendors = new Meteor.Collection("vendors")
Messages = new Meteor.Collection("messages")
VENDOR_TIMEOUT = 60*1000

if Meteor.isClient
  Meteor.call 'getEnvironment', (error, result)->
    Session.set 'environment', result
  isAdmin = ->
    Meteor.user()?.profile.admin

  Handlebars.registerHelper "isAdmin", isAdmin
  Handlebars.registerHelper "environment", ->
    Session.get 'environment'

  Template.vendorSelection.nominatedVendors = ->
    Vendors.find({nominated: true})

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

  Template.chat.messages = ->
    Messages.find({})

  Template.chat.time = ->
    "#{@created_at.getHours()}:#{@created_at.getMinutes()}"

  Template.chat.events(
    'submit .new-message': (e)->
      e.preventDefault()
      Messages.insert name: Meteor.user().profile.name, created_at: new Date(), body: $(e.currentTarget).find('input').val()
      $(e.currentTarget).find('input').val('')
  )

  Messages.find({}).observe(
    added: ->
      el = $('.messages')[0]
      if el
        setTimeout(->
          el.scrollTop = el.scrollHeight
        , 50)
  )




  Template.vendorNomination.vendors = ->
    Vendors.find()

  Template.vendorNomination.events(
    'submit .new-vendor': (e)->
      e.preventDefault()
      Vendors.insert name: $(e.currentTarget).find('input').val(), nominated: true, participants: []

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

    if Meteor.call('getEnvironment') == 'development'
      Meteor.users.find().forEach (user)->
        Meteor.users.update(user._id, $set: { 'profile.admin': true })

    # observe nominations without participants
    Vendors.find({nominated: true, participants: {$size: 0}}).observe(
      added: (vendor)->
        token = Random.id()
        console.log "watching #{vendor.name} (#{token}), will denominate in 60s unless someone participates"
        Vendors.update vendor._id, $set: { watched_at: new Date(), watch_token: token }
        Meteor.setTimeout(->
          console.log "denominate #{vendor.name} (#{token}) after 60s"
          Vendors.update { _id: vendor._id, watch_token: token, participants: { $size: 0 }}, $set: { nominated: false }
        , VENDOR_TIMEOUT)
    )

  Meteor.methods(
    getEnvironment: ->
      if(process.env.ROOT_URL == "http://localhost:3000/")
        "development"
      else
        "production"
  )

