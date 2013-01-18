module Bogus
  class Shadow
    attr_reader :calls

    def initialize(&default_return_value)
      @calls = []
      @stubs = {}
      @defaults = Hash.new(default_return_value)
      @required = Set.new
    end

    def run(method_name, *args)
      interaction = Interaction.new(method_name, args)
      @calls << interaction
      return_value(interaction)
    end

    def has_received(name, args)
      @calls.include?(Interaction.new(name, args))
    end

    def stubs(name, *args, &return_value)
      interaction = Interaction.new(name, args)
      add_stub(interaction, return_value)
      override_default(name, args, return_value)
      @required.delete(interaction)
      interaction
    end

    def mocks(name, *args, &return_value)
      interaction = stubs(name, *args, &return_value)
      @required.add(interaction)
    end

    def unsatisfied_interactions
      @required.to_a - @calls
    end

    private

    def override_default(method, args, return_value)
      return unless args == [AnyArgs]
      @defaults[method] = return_value
    end

    def add_stub(interaction, return_value_block)
      @stubs[interaction] = return_value_block if return_value_block
    end

    def return_value(interaction)
      return_value = @stubs.fetch(interaction, @defaults[interaction.method])
      return_value.call
    end
  end
end
