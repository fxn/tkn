# encoding: utf-8

slide <<-EOS, :center
  \e[1mConstant Autoloading in Ruby on Rails\e[0m


  Xavier Noria
  @fxn

  BaRuCo 2012
EOS

slide <<-EOS, :code
  require 'application_controller'
  require 'post'

  class PostsController < ApplicationController
    def index
      @posts = Post.all
    end
  end
EOS

slide <<-EOS, :code
  class PostsController < ApplicationController
    def index
      @posts = Post.all
    end
  end
EOS

section "Constants Refresher" do
  slide <<-EOS, :code
    X = 1
  EOS

  slide <<-EOS, :code
    class C
    end
  EOS

  slide <<-EOS, :code
    # ordinary class definition
    class C < D
      include M
    end

    # equivalent modulus details
    C = Class.new(D) do
      include M
    end
    
    # class name comes from the constant
    C.name # => "C"
  EOS

  slide <<-EOS, :code
    ArgumentError      FalseClass
    Array              Fiber
    BasicObject        File
    Bignum             FileTest
    Binding            Fixnum
    Class              Float
    Comparable         GC
    Complex            Gem
    Config             Hash
    Dir                IO
    Encoding           IOError
    EncodingError      IndexError
    Enumerable         Integer
    Enumerator         Interrupt
    Errno              Kernel
    Exception          ...
  EOS

  slide <<-EOS, :block
    Constants are stored in modules
  EOS

  slide <<-EOS, :code
    # rubinius/kernel/common/module.rb
    
    class Module
      attr_reader :constant_table
      attr_writer :method_table
      ...
    end
  EOS

  slide <<-EOS, :code
    module M
      X = 1
    end
  EOS

  slide <<-EOS, :code
    # ordinary class definition in namespace
    module XML
      class SAXParser
      end
    end
    
    # equivalent modulus details to
    module XML
      SAXParser = Class.new
    end
  EOS

  slide <<-EOS, :center
    Constants API
  EOS

  slide <<-EOS, :center
    Constant Name Resolution (1)
  EOS

  slide <<-EOS, :code
    module M
      X = 1
    end
  EOS

  slide <<-EOS, :code
    module Admin
      class UsersController < ApplicationController
      end
    end
  EOS

  slide <<-EOS, :center
    Constant Name Resolution (2)
  EOS

  slide <<-EOS, :code
    M::X
  EOS

  slide <<-EOS, :center
    Constant Name Resolution (3)
  EOS

  slide <<-EOS, :code
    module M
      module N
        class C < D
          X
        end
      end
    end
  EOS
end

section "Constant Autoloading" do
  slide <<-EOS, :code
    module Admin
      class UsersController < ApplicationController
        def index
          @users = User.all
        end
      end
    end
  EOS

  slide <<-EOS, :code
    # active_support/dependencies.rb

    def self.const_missing(const_name)
      name       # => "Admin::UsersController"
      const_name # => :User
    end
  EOS

  slide <<-EOS, :code
    config.autoload_paths
  EOS

  slide <<-EOS, :block
    admin/users_controller/user.rb
    admin/users_controller/user

    # trade-offs

    admin/user.rb
    admin/user

    # trade-offs

    user.rb # FOUND
  EOS

  slide <<-EOS, :code
    class Contact < ActiveRecord::Base
      after_commit :register_event

      def register_event
        Worker::EventRegister.perform_async(...)
      end
    end
  EOS

  slide <<-EOS, :block
    contact/worker.rb
    contact/worker

    # trade-offs

    worker.rb
    worker # FOUND
  EOS

  slide <<-EOS, :code
    Object.const_set("Worker", Module.new)
  EOS

  slide <<-EOS, :block
    We keep track of:

      * Fully qualified names of autoloaded constants

      * Their corresponding file names
  EOS

  slide <<-EOS, :center
    Kernel#load and Kernel#require are wrapped
  EOS

  # slide <<-EOS, :center
  #   require_dependency "sti_grandchildren"
  # EOS

  slide <<-EOS, :block
    Problem: Which Is The Nesting?
  EOS

  slide <<-EOS, :code
    # active_support/dependencies.rb

    def self.const_missing(const_name)
      name       # => "Admin::UsersController"
      const_name # => :User
    end
  EOS

  slide <<-EOS, :code
    module M
      module N
        # nesting: [M::N, M]
      end
    end

    module M::N
      # nesting: [M::N]
    end

    module A::B
      module M::N
        # nesting: [M::N, A::B]
      end
    end
  EOS

  slide <<-EOS1, :code
    module M
      Module.new.module_eval <<-EOS
        # nesting: [#<Module:0x007fa4a284f708>, M]
      EOS
    end
  EOS1

  slide <<-EOS, :center
    Trade-off for Named Modules:
  EOS

  slide <<-EOS, :center
    The name reflects the nesting
  EOS

  slide <<-EOS, :code
    module M
      module N
        # nesting: [M::N, M]
      end
    end
  EOS

  slide <<-EOS, :center
    Trade-off for Anonymous Modules
  EOS

  slide <<-EOS, :code
    # active_support/dependencies.rb

    def const_missing(const_name)
      from_mod = anonymous? ? ::Object : self
      ...
    end
  EOS

  slide <<-EOS, :block
    Problem: Which Is The Resolution Algorithm?
  EOS

  slide <<-EOS, :code
    X = 1

    module M
      X # => 1
    end

    M::X # => NameError
  EOS

  slide <<-EOS, :center
    Trade-off
  EOS

  slide <<-EOS, :code
    # active_support/dependencies.rb

    from_mod.parents.any? do |p|
      p.const_defined?(const_name, false)
    end
  EOS

  slide <<-EOS, :center
    No attempt is made to follow ancestors
  EOS

  slide <<-EOS, :center
    Corollary: Active Support does not emulate
    constant name resolution algorithms
  EOS
end

section "Request Flow" do
  slide <<-EOS, :code
    config.cache_classes
  EOS

  slide <<-EOS, :code
    ActiveSupport::FileUpdateChecker
  EOS

  slide <<-EOS, :code
    config.autoload_once_paths
    config.explicitly_unloadable_constants
  EOS

  slide <<-EOS, :code
    # rails/application.rb

    unless config.cache_classes
      middleware.use ActionDispatch::Reloader, ...
    end
  EOS

  slide <<-EOS, :block
    What is watched and reloaded:

      * Routes

      * Locales

      * Application files:
          
          - Ruby files under autoload_*

          - db/(schema.rb|structure.sql)
  EOS

  slide <<-EOS, :center
    If files have changed, autoloaded constants
    are wiped at the beginning of the request
  EOS

  slide <<-EOS, :code
    # active_support/dependencies.rb

    autoloaded_constants.each do |const|
      remove_constant const
    end

    explicitly_unloadable_constants.each do |const|
      remove_constant const
    end
  EOS

  slide <<-EOS, :center
    Constant access triggers const_missing again
    because the constants are gone
  EOS
end

section "That's all, thanks!" do
end

__END__

section 'Constant Autoloading Gotchas' do
end

slide <<-EOS, :block
  Problem 3: Ruby autoload
EOS

slide <<-EOS, :center
  autoload uses require
EOS

slide <<-EOS, :block
  require 'foo'

  # TROLOLOL
  $".delete_at(-1)

  require 'foo'
EOS

slide <<-EOS, :center
  # app/models/admin.rb
  # app/models/admin/user.rb

  module Admin
    autoload :User, 'app/models/admin/user'
  end
EOS

slide <<-EOS, :block
  no API for removing autoloads
EOS
