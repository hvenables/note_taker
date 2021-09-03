# frozen_string_literal: true

require_relative "note_taker/version"
require_relative 'note_taker/note.rb'

module NoteTaker
  class Error < StandardError; end

  HELP_TEXT = <<~HELP.freeze
    hello [OPTION] ... DIR

    -h, --help:
      show help

    --quick, -q:
      Open note for quick editing note taker exits after

    --view, -v:
      Output contents of selected note
  HELP

  DEFAULT_CONFIG = { 'general' => { 'directory' => 'work_notes' } }.freeze
  @config = begin
              YAML.safe_load(File.read("#{ENV['HOME']}/.note_config.yaml"))
            rescue Errno::ENOENT
              DEFAULT_CONFIG
            end

  class << self
    attr_reader :config, :options

    def run
      fetch_options

      catch(:app_quit) { inline? ? run_inline : run_fullscreen }

      return puts("\n") if inline?

      puts("\nGoodbye\n")
    end

    def inline?
      options[:inline]
    end

    def header
      system("clear && printf '\e[3J'")
      puts('+------------------------------------------------------------------------------+')
      puts('|                                  Note Taker                                  |')
      puts('+------------------------------------------------------------------------------+')
    end

    private

    def fetch_options
      opts = GetoptLong.new(
        ['--help', '-h', GetoptLong::NO_ARGUMENT],
        ['--quick-edit', '-q', GetoptLong::NO_ARGUMENT],
        ['--view', '-v', GetoptLong::NO_ARGUMENT]
      )

      quick_edit = false
      help = false
      view = false
      inline = false

      opts.each do |opt, _arg|
        case opt
        when '--help'
          puts HELP_TEXT
          exit 0
        when '--quick-edit'
          quick_edit = true
          inline = true
        when '--view'
          view = true
          inline = true
        end
      end

      @options = { help: help, quick_edit: quick_edit, view: view, inline: inline }
    end

    def run_inline
      catch(:quit) do
        note = Note.search

        if options[:view]
          note.view
        elsif options[:quick_edit]
          note.edit
        end
      end
    end

    def main_prompt
      @main_prompt ||= TTY::Prompt.new(quiet: true, interrupt: -> { throw(:app_quit) })
    end

    def main_menu
      header
      main_prompt.select('Main menu:') do |menu|
        menu.choice(name: 'View/Edit Notes', value: 1)
        menu.choice(name: 'Create Notes', value: 2)
        menu.choice(name: 'Delete Notes', value: 3)
      end
    end

    def run_fullscreen
      loop do
        choice = main_menu

        catch(:quit) do
          loop do
            header

            case choice
            when 1
              note = Note.search
              note.view
            when 2
              note = Note.create
              note.edit
              note.view
              choice = 1 # jump back to search mode
            when 3
              note = Note.search(prompt_message: 'Which note do you want to delete?')
              note.delete
            end
          end
        end
      end
    end
  end
end
