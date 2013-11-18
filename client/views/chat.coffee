Template.chat.messages = ->
  Messages.find({}, { sort: { created_at: -1 } }).map (msg)->
    msg.body= msg.body.split("\n")
    msg

Template.chat.time = ->
  minutes = @created_at.getMinutes()
  minutes = "0#{minutes}" if "#{minutes}".length < 2
  "#{@created_at.getHours()}:#{minutes}"

Template.chat.events(
  'submit .new-message': (e)->
    e.preventDefault()
    $input = $(e.currentTarget).find('input')
    message = $input.val()

    # is it a plain text message command?
    if message[0] == '/'
      # it's a command -> handle it
      handleCommand(message)
    else
      # it's a plain text message -> add it
      Messages.insert name: Meteor.user().profile.name, created_at: new Date(), body: $input.val()

    $input.val('')
)

Template.chat.helpers(
  firstNameOf: (name)-> name.split(' ')[0]
)

handleCommand = (command)->
  # distinguish between admin only commands and the ones everybody can use
  if Meteor.user()?.profile.admin
    command = command.replace(/[ \t]+$/,'')
    if command == '/clear'
      # clear chat history
      Meteor.call 'clearChat'

    else if command.substring(0,3) == '/h ' || command.substring(0,6) == '/hint '
      # show a flashy hint noone will overlook
      message = command.replace(/^\/hint/,'').replace(/^\/h/,'').replace(/^[ \t]+/,'')
      Messages.insert name: 'ACHTUNG', created_at: new Date(), body: message, type: 'hint'

    else if command == '/?' || command == '/help'
      Messages.insert name: 'HILFE', created_at: new Date(), body: "/clear - Chatverlauf löschen\n/h [text], /hint [text] - [text] als auffälligen Hinweis darstellen\n/r [name], /remove [name] - die Fressstätte [name] entfernen\n/?, /help - verfügbare Befehle auflisten\n/r, /reset Teilnahmen zurücksetzen", privateFor: Meteor.user()._id, type: 'help'

    else if command.substring(0,3) == '/r ' || command.substring(0,8) == '/remove '
      Meteor.call 'removeVendor', command.replace(/^\/remove/,'').replace(/^\/r/,'').replace(/^[ \t]+/,'')

    else if command == '/r' || command == '/reset'
      Meteor.call 'resetParticipants'

    else
      # unknown command
      Messages.insert name: 'FEHLER', created_at: new Date(), body: "Unbekannter Befehl: #{command}", privateFor: Meteor.user()._id, type: 'error'
  else
    Messages.insert name: 'FEHLER', created_at: new Date(), body: 'Kein Admin, keine Kommandos!', privateFor: Meteor.user()._id, type: 'error'