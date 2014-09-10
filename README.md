# Terminal Keynote

![Terminal Keynote Cover](https://raw.github.com/fxn/tkn/master/screenshots/terminal-keynote-cover.png)

## Introduction

Terminal Keynote is a quick and dirty script I wrote for presenting my talks at [BaRuCo 2012](http://baruco.org) and [RailsClub 2012](http://railsclub.ru).

Slides are written in Ruby. See the [examples folder](https://github.com/fxn/tkn/tree/master/examples).

This is a total hack. It is procedural, uses a global variable, it has not been parametrized or generalized in any way. It was tailor-made for what I exactly wanted but some people in the audience asked for the script. Even if it is quick and dirty I am very happy to share it so I have commented the source code and there you go!

## Markup

None, just text going to a terminal.

If you want a list type "*"s. If you want bold face or colors use [ANSI escape sequences](http://en.wikipedia.org/wiki/ANSI_escape_code). There are [a few gems](https://www.ruby-toolbox.com/categories/Terminal_Coloring) that may help, but take into account that creating them in Ruby is very easy using "\e" for ESC in a string with double-quotes semantics like the heredoc literals you'll see in the examples. For example

    \e[1mConstant Autoloading in Ruby on Rails\e[0m

makes the title in the cover above to appear in bold, and

    \e[31;1m21.64\e[0m

prints "21.64" in red and also using a bold face.

Also, old-school [box drawing characters](https://en.wikipedia.org/wiki/Box-drawing_characters) may give a nice touch to your slides:

![Terminal Keynote Box Drawing Characters](https://raw.github.com/fxn/tkn/master/screenshots/terminal-keynote-box-drawing-characters.png)

These are the basic ones for copy & paste:

    ┌───┬───┐
    │   │   │
    ├───┼───┤
    │   │   │
    └───┴───┘

## Syntax Highlighting

Terminal Keynote is text-based, but with style! Syntax highlighting is done on the fly with @tmm1's [pygments.rb](https://github.com/tmm1/pygments.rb). The script uses the "terminal256" formatter and "bw" style, the lexer is "ruby" by default but this can be overriden in code slides.

## Master Slides

There are five types of slides:

### code

A slide with source code.

The listing is syntax highlighted on the fly. If you want to put a title or file name or something use source code comments and imagination.

The `code` method accepts a second argument with the name of the programming language, defaults to `:ruby`.

```ruby
code <<-EOS
  # rubinius/kernel/common/module.rb

  class Module
    attr_reader :constant_table
    attr_writer :method_table
    ...
  end
EOS
```

![Terminal Keynote Code](https://raw.github.com/fxn/tkn/master/screenshots/terminal-keynote-code.png)

### center

A slide whose text is centered line by line.

Note that you can write the lines against the left margin just normal, Terminal Keynote will take care of centering them. This is illustrated in the following example.

```ruby
center <<-EOS
  Corollary: Active Support does not emulate
  constant name resolution algorithms
EOS
```

![Terminal Keynote Center](https://raw.github.com/fxn/tkn/master/screenshots/terminal-keynote-center.png)

### block

A slide with text content whose formatting is preserved, but that is centered as a whole in the screen. Do that with CSS, ha!

I find centering content in the screen as a block to be more aesthetically pleasant that flushing against the left margin. There is no way to flush against a margin.

```ruby
block <<-EOS
  What is watched and reloaded:

    * Routes

    * Locales

    * Application files:

        - Ruby files under autoload_*

        - db/(schema.rb|structure.sql)
EOS
```

![Terminal Keynote Block](https://raw.github.com/fxn/tkn/master/screenshots/terminal-keynote-block.png)

### image

A slide with an image.

This is only supported in [iTerm2](http://www.iterm2.com/), and you need to turn the blending level to the max to see the image normally (otherwise you'll see it with kind of a translucent layer on top). To do so move the "Blending" slider in Preferences > Profiles > Window all the way to the right.

```ruby
image 'elements.png'
```

![Terminal Keynote Image](https://raw.github.com/fxn/tkn/master/screenshots/terminal-keynote-image.png)

### section

Sections have a title and draw kind of a fleuron. This is also hard-coded because it is what I wanted.

Sections allow you to group slides in your Ruby slide deck, and since they yield to a block you can collapse/fold the ones you are not working on for focus.

The nested structure is not modeled internally. The script only sees a flat linear sequence of slides.

```ruby
section "Constants Refresher" do
  code <<-EOS
    X = 1
  EOS

  ...
end
```

![Terminal Keynote Section](https://raw.github.com/fxn/tkn/master/screenshots/terminal-keynote-section.png)

## Visual Effects

There is one hard-coded visual effect: Once the exact characters of a given slide are computed, we print char by char with a couple milliseconds in between. That gives the illusion of an old-school running cursor. Configure block blinking cursor for maximum awesomeness.

## Keyboard Controls and Remotes

* To go forward press any of " ", "n", "k", "l", Right, PageDown (but see below).

* To go backwards press any of "b", "p", "h", "j", Left, PageUp (but see below).

* First slide: "^".

* Last slide: "$".

* Go to slide: "g".

* Search for slide: "/".

* Toggle status: "s".

* Quit: "q".

Searching accepts a regular expression. A nice trick to enable a modifier in a particular search is to use the

    (?imx−imx:...)

syntax. For example to look for "constant" in a case-insensitive way just enter

    Search for: (?i:constant)

My Logitech remote emits PageDown and PageUp. You get those as "\e[5~" and "\e[6~" respectively and the script understands them, but you need to [configure them in Terminal.app](http://fplanque.com/dev/mac/mac-osx-terminal-page-up-down-home-end-of-line) and also tell it to pass them down to the shell selecting "send string to the shell" in the "Action" selector.

## Font and Terminal Configuration

I used Menlo, 32 points. That gives 18x52 in a screen resolution of 1024x768.

For your preferred setup, find out the resolution of the projector of your conference (ask the organization in advance). Set the screen to that resolution, choose font and font size and maximize window, and write down the number of rows and columns. Depending on your terminal configuration they may be displayed in the title bar of the window. Run `stty size` otherwise.

Then, define in your terminal a profile for the conference, choose a theme you like and configure those settings. In particular set the initial rows and cols to those figures. That way the terminal will launch with all set no matter the screen resolution and you can hack your talk in your day to day with the native resolution, seeing how it is going to look in proportion.

## Editor Snippets

A snippet for your editor is basic to write slides quickly. The [extras folder](https://github.com/fxn/tkn/tree/master/extras) has a snippet for Sublime Text 2.

## Cathode

[Cathode](http://www.secretgeometry.com/apps/cathode/) is perfect for this thing. But because of how it draws the text it doesn't do bold faces and may not be able to render some colors or Unicode characters. YMMV.


## Installation

### Packaging

By now Terminal Keynote is not going to be a gem, please clone the repo and hack your talk. In its current state it is just too tailor-made for anything but personal forks. Please keep the script together with the slides, that way you guarantee one year later the presentation will still run.

If Terminal Keynote evolves it is going to do so in backwards incompatible ways for sure. So, let's wait. If the thing ever converges to something that can be packaged then I'll do it.

### Requirements

Terminal Keynote needs [Ruby 1.9 or 2.0](http://www.ruby-lang.org) and [Pygments](http://pygments.org).

Once those are installed run `gem install bundler`, root privs may be needed. Then cd into the directory with your `tkn` clone and run `bundle`, this installs the Ruby dependencies.

All set, to launch the example run

    bundle exec bin/tkn examples/constant_autoloading_in_ruby_on_rails.rb

## License

Released under the MIT License, Copyright (c) 2012–<i>ω</i> Xavier Noria.
