# Credit:
# special thanks to Vagrant project: https://github.com/mitchellh/vagrant
# where the source of this module was originally extracted.

module Vli
  module Command
    class Base
      include Util::SafePuts
      
      def initialize(argv, env)
        @argv   = argv
        @env    = env
      end

      def execute; end

      # Parses the options given an OptionParser instance.
      #
      # This is a convenience method that properly handles duping the
      # originally argv array so that it is not destroyed.
      #
      # This method will also automatically detect "-h" and "--help"
      # and print help. And if any invalid options are detected, the help
      # will be printed, as well.
      #
      # If this method returns `nil`, then you should assume that help
      # was printed and parsing failed.
      def parse_options(opts=nil)
        # Creating a shallow copy of the arguments so the OptionParser
        # doesn't destroy the originals.
        argv = @argv.dup

        # Default opts to a blank optionparser if none is given
        opts ||= OptionParser.new

        # Add the help option, which must be on every command.
        opts.on_tail("-h", "--help", "Print this help") do
          safe_puts(opts.help)
          return nil
        end

        opts.parse!(argv)
        return argv
      rescue OptionParser::InvalidOption
        raise Error::CLIInvalidOptions, :help => opts.help.chomp
      end

      # This method will split the argv given into three parts: the
      # flags to this command, the subcommand, and the flags to the
      # subcommand. For example:
      #
      #     -v status -h -v
      #
      # The above would yield 3 parts:
      #
      #     ["-v"]
      #     "status"
      #     ["-h", "-v"]
      #
      # These parts are useful because the first is a list of arguments
      # given to the current command, the second is a subcommand, and the
      # third are the commands given to the subcommand.
      #
      # @return [Array] The three parts.
      def split_main_and_subcommand(argv)
        # Initialize return variables
        main_args   = nil
        sub_command = nil
        sub_args    = []

        # We split the arguments into two: One set containing any
        # flags before a word, and then the rest. The rest are what
        # get actually sent on to the subcommand.
        argv.each_index do |i|
          if !argv[i].start_with?("-")
            # We found the beginning of the sub command. Split the
            # args up.
            main_args   = argv[0, i]
            sub_command = argv[i]
            sub_args    = argv[i + 1, argv.length - i + 1]

            # Break so we don't find the next non flag and shift our
            # main args.
            break
          end
        end

        # Handle the case that argv was empty or didn't contain any subcommand
        main_args = argv.dup if main_args.nil?

        return [main_args, sub_command, sub_args]
      end

    end
  end
end