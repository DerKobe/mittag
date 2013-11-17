@Messages = new Meteor.Collection('messages')

Meteor.publish 'messages', ->
  Messages.find({ privateFor: { $in: [@userId, null] } }, { limit: 100 })

Messages.allow(
  insert: (userId, message)-> true
)

Meteor.methods(
  clearChat: ->
    Messages.remove({}) if Meteor.user()?.profile.admin
)