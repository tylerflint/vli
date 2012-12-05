# TODO:
# * env.lock

module Vli
  module Action
    class Runner
      @@reported_interrupt = false

      def initialize(registry, globals=nil, &block)
        @registry     = registry
        @globals      = globals || {}
        @lazy_globals = block
      end

      def run(callable_id, options=nil)
        callable = callable_id
        callable = Builder.new.use(callable_id) if callable_id.kind_of?(Class)
        callable = @registry.get(callable_id) if callable_id.kind_of?(Symbol)
        raise ArgumentError, "Argument to run must be a callable object or registered action." if !callable || !callable.respond_to?(:call)

        # Create the initial environment with the options given
        environment = Environment.new
        environment.merge!(@globals)
        environment.merge!(@lazy_globals.call) if @lazy_globals
        environment.merge!(options || {})

        # Run the action chain in a busy block, marking the environment as
        # interrupted if a SIGINT occurs, and exiting cleanly once the
        # chain has been run.
        ui = environment[:ui] if environment.has_key?(:ui)
        int_callback = lambda do
          if environment[:interrupted]
            ui.error exit_immediately_message if ui
            abort
          end

          ui.warn waiting_cleanup_message if ui && !@@reported_interrupt
          environment[:interrupted] = true
          @@reported_interrupt = true
        end

        # We place a process lock around every action that is called
        Util::Busy.busy(int_callback) { callable.call(environment) }
      end

      def exit_immediately_message
        "Exiting immediately, without cleanup!"
      end

      def waiting_cleanup_message
        "Waiting for cleanup before exiting..."
      end

    end
  end
end
