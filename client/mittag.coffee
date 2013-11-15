@Vendors = new Meteor.Collection('vendors')
@Messages = new Meteor.Collection('messages')

Meteor.subscribe('vendors')
Meteor.subscribe('messages')

Meteor.call 'getEnvironment', (error, result)->
  Session.set 'environment', result
isAdmin = ->
  Meteor.user()?.profile.admin

Handlebars.registerHelper 'isAdmin', isAdmin
Handlebars.registerHelper 'environment', ->
  Session.get 'environment'

Template.userInfo.onlineUsers = ->
  Meteor.users.find("profile.online": true)

jQuery ->
  $(document).foundation();
