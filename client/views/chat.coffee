Template.chat.messages = ->
  Messages.find({}, sort: { created_at: -1 })

Template.chat.time = ->
  minutes = @created_at.getMinutes()
  minutes = "0#{minutes}" if "#{minutes}".length < 2
  "#{@created_at.getHours()}:#{minutes}"

Template.chat.events(
  'submit .new-message': (e)->
    e.preventDefault()
    $input = $(e.currentTarget).find('input')
    Messages.insert name: Meteor.user().profile.name, created_at: new Date(), body: $input.val()
    $input.val('')
)

Template.chat.helpers(
  firstNameOf: (name)-> name.split(' ')[0]
)