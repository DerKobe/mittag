@Messages = new Meteor.Collection('messages')

Meteor.publish 'messages', ->
  return Messages.find({}, { limit: 100 })

Messages.allow(
  insert: (userId, message)->
    true
)