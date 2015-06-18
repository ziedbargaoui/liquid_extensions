module Locomotive
  module LiquidExtensions
    module Tags

      class Teaser < Solid::Tag


        def render(context)

          context_test = Hash.new
          context_test[:site] = context.registers[:site]

          content = ""
          context.registers[:page].snippet_dependencies.each do |i|
            content = content + "{% include '#{i}' %}"
          end

          @template = ::Liquid::Template.parse(content,context.merge(context_test))

          rend = @template.render(context)

          return rend

        end

      end

      ::Liquid::Template.register_tag('teaser', Teaser)
    end
  end
end
