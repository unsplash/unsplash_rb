# unsplash_rb

[![Build Status](https://travis-ci.org/unsplash/unsplash_rb.svg?branch=travis)](https://travis-ci.org/unsplash/unsplash_rb)
[![Coverage Status](https://coveralls.io/repos/github/unsplash/unsplash_rb/badge.svg?branch=master&gh_cache_bust=1)](https://coveralls.io/github/unsplash/unsplash_rb?branch=master)

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
  config.application_access_key = "YOUR ACCESS KEY"
  config.application_secret = "YOUR APPLICATION SECRET"
  config.application_redirect_uri = "https://your-application.com/oauth/callback"
  config.utm_source = "alices_terrific_client_app"

  # optional:
  config.logger = MyCustomLogger.new
end
```

#### API Guidelines

All API applications must abide by the [API Guidelines](https://help.unsplash.com/api-guidelines/unsplash-api-guidelines).

As part of [the API guidelines](https://help.unsplash.com/api-guidelines/unsplash-api-guidelines), all API uses are required to use utm links when providing credit to photographers and Unsplash. Set the `config.utm_source` to your app's name to automatically append the utm source.

### Public-scope actions

If you are *only* making public requests (i.e. nothing requiring a specific logged-in user, for example liking photos or accessing private user details), then you're ready to go!

Looking for details of a specific photo? Find it by ID:

```ruby
photo = Unsplash::Photo.find("tAKXap853rY")
```

Want a bunch of pictures of cats? You're on the internet; of course you do.

```ruby
search_results = Unsplash::Photo.search("cats")
```

For a complete list of available actions, see our [documentation details](http://www.rubydoc.info/github/unsplash/unsplash_rb/).

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

Hotlinking the [Unsplash image files is required](https://help.unsplash.com/api-guidelines/more-on-each-guideline/guideline-hotlinking-images)

Unlike most APIs, Unsplash requires for the image URLs returned by the API to be directly used or embedded in your applications (generally referred to as hotlinking). By using the CDN and embedding the photo URLs in your application, Unsplash can better track photo views and pass those stats on to the photographer, providing them with context for how popular their photo is and how it's being used.

### Track Download

Do you want to trigger [track download](https://help.unsplash.com/api-guidelines/more-on-each-guideline/guideline-triggering-a-download) attribution on a photo ? 

```ruby
photo = Unsplash::Photo.find("tAKXap853rY")
photo.track_download
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/unsplash/unsplash_rb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

