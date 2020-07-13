# frozen_string_literal: true

require_relative 'base'

module Engine
  module Round
    class Operating < Base
      def name
        'Operating Round'
      end

      def select_entities
        @game.minors + @game.corporations.select(&:floated?).sort
      end

      def setup
        @home_token_timing = @game.class::HOME_TOKEN_TIMING
        @game.payout_companies
        @entities.each { |c| @game.place_home_token(c) } if @home_token_timing == :operating_round
        start_operating
      end

      def action_processed(_action)
        return if active_step || @entity_index == @entities.size - 1

        next_entity_index!
        @steps.each(&:unpass!)
        start_operating
      end

      def start_operating
        return if finished?

        @game.log << "#{current_entity.owner.name} operates #{current_entity.name}"
        current_entity.trains.each { |train| train.operated = false }
        @game.place_home_token(current_entity) if @home_token_timing == :operate
        skip_steps
      end

      def recalculate_order
        # Selling shares may have caused the corporations that haven't operated yet
        # to change order. Re-sort only them.
        index = @entity_index + 1
        @entities[index..-1] = @entities[index..-1].sort if index < @entities.size - 1
      end

    end
  end
end
