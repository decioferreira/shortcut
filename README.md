# Shortcut

Make your own Bot.

## Installation

Add this line to your application's Gemfile:

    gem 'shortcut'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shortcut

## Usage

### Ubuntu 12.04 with Unity-2D

Ubuntu has a bug related to how unity-2d draws itself on screen.
To fix this issue run the following command before you run shortcut:

    $ gconftool --set --type bool /apps/metacity/general/compositing_manager false

And then log out/in to apply the changes. To restore the default configuration run:

    $ gconftool --set --type bool /apps/metacity/general/compositing_manager true

And again log out/in to apply the changes.

See more information about this [bug](https://bugs.launchpad.net/unity-2d/+bug/1081674).

## Development

    $ ruby --ng-server &
    $ ruby --ng -S rspec spec

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Credits

* [Icons](http://www.iconarchive.com/show/soft-scraps-icons-by-deleket/Gear-icon.html)
