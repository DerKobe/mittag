@Vendors = new Meteor.Collection('vendors')
@Messages = new Meteor.Collection('messages')

isAdmin = ->
  Meteor.user()?.profile.admin

Meteor.subscribe('vendors', ->
  if user = Meteor.user()
    vendor = Vendors.findOne({'participants._id': user._id})
    Session.setDefault('selectedVendor', vendor)
)
Meteor.subscribe('messages')

Meteor.call 'getEnvironment', (error, result)->
  Session.set 'environment', result

Handlebars.registerHelper 'isAdmin', isAdmin
Handlebars.registerHelper 'environment', ->
  Session.get 'environment'

Template.userInfo.onlineUsers = ->
  Meteor.users.find("profile.online": true)

jQuery ->
  $(document).foundation();
