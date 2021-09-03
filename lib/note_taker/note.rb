class Note
  class << self
    def create
      prompt.say('What is the filename of the note you want to create? (or press ctrl+c to abort)')
      input = prompt.ask('‣') do |q|
        q.required true
      end

      filepath = "#{ENV['HOME']}/#{dir}/#{input}.md".shellescape
      `touch #{filepath}`
      new(input)
    end

    def search(prompt_message: 'Choose a note.')
      if filenames.empty?
        prompt.puts('Folder currently empty')
        return
      end

      input = prompt.select(
        prompt_message,
        filenames,
        filter: true,
        per_page: 40,
        help: '(or press ctrl+c to abort)',
        show_help: :always
      )
      new(input)
    end

    def dir
      NoteApplication.config['general']['directory']
    end

    def prompt
      @prompt ||= TTY::Prompt.new(quiet: true, interrupt: -> { throw(:quit) })
    end

    private

    def filenames
      `ls ~/#{dir}`.split("\n").map { |file| file.chomp('.md') }
    end
  end

  attr_reader :filename, :location

  def initialize(filename)
    @filename = filename
  end

  def view
    catch(:note_quit) do
      loop do
        NoteApplication.header unless NoteApplication.inline?
        parsed = TTY::Markdown.parse_file(file_path)
        NoteApplication.options[:inline] ? puts(parsed) : prompt.puts(parsed)
        prompt.puts("\n")

        break if NoteApplication.inline?

        note_menu
      end
    end
  end

  def edit
    TTY::Editor.open(file_path)
  end

  def delete
    return unless prompt.yes?("Are you sure you want to delete '#{filename}'")

    `rm #{file_path.shellescape}`
  end

  private

  def note_menu
    choices = [
      { key: 'e', name: 'edit', value: :edit },
      { key: 'r', name: 'rename', value: :rename },
      { key: 'd', name: 'delete', value: :delete },
      { key: 'q', name: 'quit', value: :quit }
    ]
    input = prompt.expand('Action:', choices)

    case input
    when :edit
      edit
    when :rename
      rename
    when :delete
      delete
      throw(:note_quit)
    when :quit
      throw(:note_quit)
    end
  end

  def rename
    input = prompt.ask('What is the new filename?')

    new_filename = input.shellescape
    `mv #{file_path.shellescape} #{path}#{new_filename}.md"`
    @filename = input
  end

  def path
    "#{ENV['HOME']}/#{self.class.dir}/"
  end

  def file_path
    "#{path}#{filename}.md"
  end

  def prompt
    self.class.prompt
  end
end
