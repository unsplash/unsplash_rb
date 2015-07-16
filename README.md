# unsplash_rb

[ ![Codeship Status for CrewLabs/unsplash_rb](https://codeship.com/projects/0d395ea0-fe45-0132-5e19-022bf5e0402e/status?branch=master)](https://codeship.com/projects/88039)

A ruby client for [the Unsplash API](https://unsplash.com/documentation).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'unsplash'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install unsplash

## Usage

### Configuration

Before making requests, you must configure the gem with your application ID
and secret. If you are using Rails, you can do this in an initializer. 

```ruby
Unsplash.configure do |config|    
  config.application_id     = "YOUR APPLICATION ID"    
  config.application_secret = "YOUR APPLICATION SECRET"
  config.application_redirect_uri = "https://your-application.com/oauth/callback"
end
```

### Public-scope actions

If you are *only* making public requests (i.e. nothing requiring a specific logged-in user,
for example photo uploads or private user details), then you're ready to go!

Looking for details of a specific photo? Find it by ID:

```ruby
photo = Unsplash::Photo.find("tAKXap853rY")
```

Want a bunch of pictures of cats? You're on the internet; of course you do.

```ruby
search_results = Unsplash::Photo.search("cats")
```

For a complete list of available actions, see our [documentation details](http://www.rubydoc.info/github/CrewLabs/unsplash_rb).

### User Authorization

For non-public actions, you'll have to get the user's permission to access their data.
Direct them to the Unsplash authorization URL:

```ruby
requested_scopes = ["public", "read_user", "something_else_you_are_asking_for"]
auth_url = Unsplash::Client.connection.authorization_url(requested_scopes)
```

Upon authorization, Unsplash will return to you an authentication code via your OAuth
callback handler. With that you can generate an access token:

```ruby
Unsplash::Client.connection.authorize!("the authentication code")
```

And that's it. The API actions will be available to you according to whichever
permission scopes you requested and the user authorized.

### Hotlinking

Hotlinking the Unsplash image files is encouraged: https://unsplash.com/documentation#hotlinking

Unlike most APIs, Unsplash prefers for the image URLs returned by the API to be directly used or embedded in your applications (generally referred to as hotlinking). By using the CDN and embedding the photo URLs in your application, Unsplash can better track photo views and pass those stats on to the photographer, providing them with context for how popular their photo is and how it's being used.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/crewlabs/unsplash_rb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

