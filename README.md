# NoteTaker

Just a small ruby gem to help you keep your notes.

It uses your default editor ($EDITOR) to open the markdown notes that it creates.

## Installation

To use note_taker just install it with the below

    $ gem install note_taker

## Usage

The default directory is `~/work_notes` if you want to change this you need to add a `~/.note_config.yaml`. Then add the
following to the config
```yaml
general:
  directory: <path-to-notes-dir>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/note_taker.
