@Vendors = new Meteor.Collection('vendors')
@Messages = new Meteor.Collection('messages')
@VENDOR_TIMEOUT = 60*1000

Meteor.methods(
  getEnvironment: ->
    if(process.env.ROOT_URL == "http://localhost:3000/")
      "development"
    else
      "production"
)