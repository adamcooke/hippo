# frozen_string_literal: true

module Hippo
  class DeploymentMonitor
    def initialize(stage, deployment_id, sleep: 4, count: 15)
      @stage = stage
      @deployment_id = deployment_id
      @sleep = sleep
      @count = count
    end

    def on_wait(&block)
      @on_wait = block
    end

    def on_failure(&block)
      @on_failure = block
    end

    def on_success(&block)
      @on_success = block
    end

    def wait
      count = 0
      loop do
        sleep @sleep
        poll = Poll.new(@stage, @deployment_id)
        if poll.pending.empty?
          @on_success&.call(poll)
          return true
        else
          if count >= @count
            @on_failure&.call(poll)
            return false
          else
            count += 1
            @on_wait&.call(poll)
          end
        end
      end
    end

    private

    class Poll
      def initialize(stage, deployment_id)
        @stage = stage
        @deployment_id = deployment_id

        @replica_sets = @stage.get(
          'rs',
          '--selector',
          'hippo.adam.ac/deployID=' + @deployment_id
        )

        @pending = @replica_sets.reject do |deploy|
          deploy['status']['availableReplicas'] == deploy['status']['replicas']
        end
      end

      attr_reader :pending
      attr_reader :replica_sets

      def pending_names
        make_names(@pending)
      end

      def names
        make_names(@replica_sets)
      end

      private

      def make_names(array)
        array.map do |d|
          d.name.split('-').first
        end
      end
    end
  end
end
