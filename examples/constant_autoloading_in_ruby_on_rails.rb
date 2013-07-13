# encoding: utf-8

center <<-EOS
  \e[1mConstant Autoloading in Ruby on Rails\e[0m


  Xavier Noria
  @fxn

  BaRuCo 2012
EOS

code <<-EOS
  require 'application_controller'
  require 'post'

  class PostsController < ApplicationController
    def index
      @posts = Post.all
    end
  end
EOS

code <<-EOS
  class PostsController < ApplicationController
    def index
      @posts = Post.all
    end
  end
EOS

section "Constants Refresher" do
  code <<-EOS
    X = 1
  EOS

  code <<-EOS
    class C
    end
  EOS

  code <<-EOS
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

  code <<-EOS
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

  center <<-EOS
    Constants are stored in modules
  EOS

  code <<-EOS
    # rubinius/kernel/common/module.rb
    
    class Module
      attr_reader :constant_table
      attr_writer :method_table
      ...
    end
  EOS

  code <<-EOS
    module M
      X = 1
    end
  EOS

  code <<-EOS
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

  center <<-EOS
    Constants API
  EOS

  center <<-EOS
    Constant Name Resolution (1)
  EOS

  code <<-EOS
    module M
      X = 1
    end
  EOS

  code <<-EOS
    module Admin
      class UsersController < ApplicationController
      end
    end
  EOS

  center <<-EOS
    Constant Name Resolution (2)
  EOS

  code <<-EOS
    M::X
  EOS

  center <<-EOS
    Constant Name Resolution (3)
  EOS

  code <<-EOS
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
  code <<-EOS
    module Admin
      class UsersController < ApplicationController
        def index
          @users = User.all
        end
      end
    end
  EOS

  code <<-EOS
    # active_support/dependencies.rb

    def self.const_missing(const_name)
      name       # => "Admin::UsersController"
      const_name # => :User
    end
  EOS

  code <<-EOS
    config.autoload_paths
  EOS

  block <<-EOS
    admin/users_controller/user.rb
    admin/users_controller/user

    # trade-offs

    admin/user.rb
    admin/user

    # trade-offs

    user.rb # FOUND
  EOS

  code <<-EOS
    class Contact < ActiveRecord::Base
      after_commit :register_event

      def register_event
        Worker::EventRegister.perform_async(...)
      end
    end
  EOS

  block <<-EOS
    contact/worker.rb
    contact/worker

    # trade-offs

    worker.rb
    worker # FOUND
  EOS

  code <<-EOS
    Object.const_set("Worker", Module.new)
  EOS

  block <<-EOS
    We keep track of:

      * Fully qualified names of autoloaded constants

      * Their corresponding file names
  EOS

  center <<-EOS
    Kernel#load and Kernel#require are wrapped
  EOS

  # center <<-EOS
  #   require_dependency "sti_grandchildren"
  # EOS

  block <<-EOS
    Problem: Which Is The Nesting?
  EOS

  code <<-EOS
    # active_support/dependencies.rb

    def self.const_missing(const_name)
      name       # => "Admin::UsersController"
      const_name # => :User
    end
  EOS

  code <<-EOS
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

  code <<-EOS1
    module M
      Module.new.module_eval <<-EOS
        # nesting: [#<Module:0x007fa4a284f708>, M]
      EOS
    end
  EOS1

  center <<-EOS
    Trade-off for Named Modules:
  EOS

  center <<-EOS
    The name reflects the nesting
  EOS

  code <<-EOS
    module M
      module N
        # nesting: [M::N, M]
      end
    end
  EOS

  center <<-EOS
    Trade-off for Anonymous Modules
  EOS

  code <<-EOS
    # active_support/dependencies.rb

    def const_missing(const_name)
      from_mod = anonymous? ? ::Object : self
      ...
    end
  EOS

  block <<-EOS
    Problem: Which Is The Resolution Algorithm?
  EOS

  code <<-EOS
    X = 1

    module M
      X # => 1
    end

    M::X # => NameError
  EOS

  center <<-EOS
    Trade-off
  EOS

  code <<-EOS
    # active_support/dependencies.rb

    from_mod.parents.any? do |p|
      p.const_defined?(const_name, false)
    end
  EOS

  center <<-EOS
    No attempt is made to follow ancestors
  EOS

  center <<-EOS
    Corollary: Active Support does not emulate
    constant name resolution algorithms
  EOS
end

section "Request Flow" do
  code <<-EOS
    config.cache_classes
  EOS

  code <<-EOS
    ActiveSupport::FileUpdateChecker
  EOS

  code <<-EOS
    config.autoload_once_paths
    config.explicitly_unloadable_constants
  EOS

  code <<-EOS
    # rails/application.rb

    unless config.cache_classes
      middleware.use ActionDispatch::Reloader, ...
    end
  EOS

  block <<-EOS
    What is watched and reloaded:

      * Routes

      * Locales

      * Application files:
          
          - Ruby files under autoload_*

          - db/(schema.rb|structure.sql)
  EOS

  center <<-EOS
    If files have changed, autoloaded constants
    are wiped at the beginning of the request
  EOS

  code <<-EOS
    # active_support/dependencies.rb

    autoloaded_constants.each do |const|
      remove_constant const
    end

    explicitly_unloadable_constants.each do |const|
      remove_constant const
    end
  EOS

  center <<-EOS
    Constant access triggers const_missing again
    because the constants are gone
  EOS
end

section "That's all, thanks!" do
end

__END__

section 'Constant Autoloading Gotchas' do
end

block <<-EOS
  Problem 3: Ruby autoload
EOS

center <<-EOS
  autoload uses require
EOS

block <<-EOS
  require 'foo'

  # TROLOLOL
  $".delete_at(-1)

  require 'foo'
EOS

center <<-EOS
  # app/models/admin.rb
  # app/models/admin/user.rb

  module Admin
    autoload :User, 'app/models/admin/user'
  end
EOS

block <<-EOS
  no API for removing autoloads
EOS
