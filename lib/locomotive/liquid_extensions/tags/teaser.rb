module Locomotive
  module LiquidExtensions
    module Tags

      class Teaser < Solid::Tag


        def render(context)

          context_test = Hash.new
          context_test[:site] = context.registers[:site]


          content = ""
          context.registers[:page].teasers_dependencies.each do |i|
            #content = content + "{% include '#{i}' %}"
            teasers_content_type = context.registers[:site].content_types.where(slug: 'teasers').first

            teasers_content_entries = context.registers[:site].content_entries.where(content_type_id: teasers_content_type.id, _slug: i)

            teasers_content_entries.each do |teaser|
              content << '<div class="home-teaser">
              <div class="home-teaser-title">'+teaser.teaser_name+'</div><hr><div class="home-teaser-content">'+teaser.teaser_body+'</div></div>'
            end
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
