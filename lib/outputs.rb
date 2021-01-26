#!/usr/bin/env ruby

# - implement new printers here, and send the class to the factory using `PrinterFactory.printers = [class]`

class PipePrinter
  include Printer

  def initialize
    super
    @keyword = 'pipe'
  end

  def print_changelog(changelog, _kwargs = {})
    validate_changelog(changelog)
    changelog.commits.each_with_index do |commit, index|
      # 0x1D is the ASCII code for the Field Separator character, which does exactly that
      printf("\x1d%<index>s\x1d%<subject>s\x1d\n", index: index, subject: commit.subject)
    end
  end
end
PrinterFactory.printers = PipePrinter

class InteractivePrinter # rubocop:disable Metrics/ClassLength
  include Printer

  ESC_CODE = 27

  def initialize
    super
    @keyword = 'interactive'
    @menu_items = []
    @commits_hash = {}
  end

  def print_changelog(changelog, _kwargs = {})
    validate_changelog(changelog)
    @changelog = changelog
    init_curses
    changelog.commits.each do |commit|
      @menu_items << Curses::Item.new(commit.subject, '')
      @commits_hash[commit.subject] = commit
    end
    build_window
    ui_loop
  end

  private

  def init_curses
    Curses.init_screen
    Curses.curs_set(0)
    Curses.noecho
  end

  def update_measures
    @height = Curses.lines
    @width = Curses.cols
    @h_w1 = @height - 4
    @w_w1 = @width - 4
    @h_p = @h_w1 - (@cury.nil? ? 0 : @cury)
    @w_p = (@w_w1 - 1) / 2
    @h_p1 = @h_p - 4
    @w_p1 = @w_p - 4
  end

  def reset_window(win, hei, wid, poy, pox, box = nil) # rubocop:disable Metrics/ParameterLists
    win&.clear
    win&.resize(hei, wid)
    win&.move_relative(poy, pox)
    win&.setpos(0, 0)
    win&.box(box, box) unless box.nil?
  end

  def build_outer
    update_measures
    prepare_main_window
    @window = @main_window.derwin(@h_w1, @w_w1, 2, 2) if @window.nil?
  end

  def update_position
    @cury = @window.cury unless @window.nil?
    @curx = @window.curx unless @window.nil?
    update_measures
  end

  def build_heading
    commits_nr = @changelog.commits.length
    reset_window(@window, @h_w1, @w_w1, 2, 2)
    @window.addstr('Subject: ')
    @window.attron(Curses::A_BOLD | Curses::A_UNDERLINE)
    @window.addstr("#{@changelog.subject}\n")
    @window.attroff(Curses::A_BOLD | Curses::A_UNDERLINE)
    @window.addstr("Status: #{@changelog.status}\n")
    @window.attron(Curses::A_UNDERLINE)
    @window.addstr(@changelog.author)
    @window.attroff(Curses::A_UNDERLINE)
    @window.addstr(" on #{@changelog.time}\n\n#{commits_nr} commit#{commits_nr > 1 ? 's' : ''} from ")
    @window.attron(Curses::A_BOLD)
    @window.addstr(@changelog.base_branch.to_s)
    @window.attroff(Curses::A_BOLD)
    @window.addstr(' to ')
    @window.attron(Curses::A_BOLD)
    @window.addstr(@changelog.target_branch.to_s)
    @window.attroff(Curses::A_BOLD)
    @window.addstr("\n")
    update_position
  end

  def build_left_panel
    begin
      @menu.unpost
    rescue StandardError
      # Unposting a menu that was never posted is harmless, and this comment is enforced by rubocop
    end
    @left_panel&.close
    @left_panel_parent&.close
    @left_panel_parent = @window.derwin(@h_p, @w_p, @cury, 0)
    @left_panel = @left_panel_parent.derwin(@h_p1, @w_p1, 2, 2)
    reset_window(@left_panel, @h_p1, @w_p1, 2, 2)
    reset_window(@left_panel_parent, @h_p, @w_p, @cury, 0, 0)
    @menu = Curses::Menu.new(@menu_items) if @menu.nil?
    @menu.set_win(@left_panel_parent)
    @menu.set_sub(@left_panel)
    @menu.set_format(@h_p1, 1)
    @menu.post
  end

  def build_right_panel
    @right_panel&.close
    @right_panel_parent&.close
    @right_panel_parent = @window.derwin(@h_p, @w_p, @cury, @w_p + 1)
    @right_panel = @right_panel_parent.derwin(@h_p1, @w_p1, 2, 2)
    reset_window(@right_panel, @h_p1, @w_p1, 2, 2)
    reset_window(@right_panel_parent, @h_p, @w_p, @cury, @w_p + 1, 0)
    @right_panel.addstr("Use the ↑ and ↓ arrows in the keyboard to navigate the commits\n")
    @right_panel.addstr("Press any key to remove this message and show the commit detail\n")
    @right_panel.addstr("Press the ESC key twice to exit this view\n\n")
    @right_panel.addstr('For more information, please run this script with the -h flag and read the manual')
  end

  def prepare_main_window
    @main_window = Curses::Window.new(@height, @width, 0, 0) if @main_window.nil?
    @main_window.keypad(true)
    @main_window.box(0, 0)
    @main_window.setpos(0, 1)
    @main_window.addstr("Changelog: #{@changelog.name} [#{@changelog.id}]")
  end

  def build_window
    build_outer
    build_heading
    build_left_panel
    build_right_panel
    prepare_main_window
  end

  def update_panel
    commit = @commits_hash[@menu.current_item.name]
    nro = @menu_items.index(@menu.current_item) + 1
    total = @menu_items.length
    reset_window(@right_panel, @h_p1, @w_p1, 2, 2)
    @right_panel.addstr("Hash: #{commit.id} \n From: ")
    @right_panel.attron(Curses::A_UNDERLINE)
    @right_panel.addstr(commit.author)
    @right_panel.attroff(Curses::A_UNDERLINE)
    @right_panel.addstr("\n Date: ")
    @right_panel.attron(Curses::A_BOLD)
    @right_panel.addstr(commit.time.to_s)
    @right_panel.attroff(Curses::A_BOLD)
    @right_panel.addstr("\nSubject [#{nro}/#{total}]: ")
    @right_panel.attron(Curses::A_BOLD | Curses::A_UNDERLINE)
    @right_panel.addstr(commit.subject)
    @right_panel.attroff(Curses::A_BOLD | Curses::A_UNDERLINE)
    @right_panel.addstr("\n\n")
    @right_panel.addstr(commit.message)
  end

  def redraw_window
    @main_window.clear
    build_window
  end

  def ui_loop # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    while (keypress = @main_window.getch) != ESC_CODE
      begin
        @menu.down_item if keypress == Curses::Key::DOWN
        @menu.up_item if keypress == Curses::Key::UP
        @menu.scroll_down_page if keypress == Curses::Key::NPAGE
        @menu.scroll_up_page if keypress == Curses::Key::PPAGE
        redraw_window if keypress == Curses::Key::RESIZE
      rescue Curses::RequestDeniedError
        next
      end
      update_panel unless keypress == Curses::Key::RESIZE
    end
  rescue Interrupt
    nil
  end
end
PrinterFactory.printers = InteractivePrinter
