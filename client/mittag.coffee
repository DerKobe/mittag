@Vendors = new Meteor.Collection('vendors')
@Messages = new Meteor.Collection('messages')

if Meteor.isClient
  Meteor.call 'getEnvironment', (error, result)->
    Session.set 'environment', result
  isAdmin = ->
    Meteor.user()?.profile.admin

  Handlebars.registerHelper 'isAdmin', isAdmin
  Handlebars.registerHelper 'environment', ->
    Session.get 'environment'

  Template.userInfo.onlineUsers = ->
    Meteor.users.find("profile.online": true)

  Messages.find().observe(
    added: ->
      el = $('.messages')[0]
      if el
        setTimeout(->
          el.scrollTop = el.scrollHeight
        , 50)
  )

  jQuery ->
    $(document).foundation();
