module Locomotive
  module LiquidExtensions
    module Tags

      class Teaser < Solid::Tag

        def display(*options, &block)

          model_name, attributes = self.extract_model_name_and_attributes(options)
          @new_att = attributes
          self.render_teasers(@current_context)
        end

        def extract_model_name_and_attributes(options)

          raise ::Liquid::Error.new('[EntriesOverview] wrong number of parameters (1 is required)') if options.size < 1

          [options.first.to_s, options.last].tap do |name, attributes|
            if attributes.is_a?(Hash)
              attributes.each do |k, v|
                # deal with the model directly instead of the liquid drop
                _source = v.instance_variable_get(:@_source)

                attributes[k] = _source if _source
              end

              # the content entry should not be attached to another site or content type
              attributes.delete_if { |k, _| %w(site site_id content_type content_type_id).include?(k) }
            else
              #raise ::Liquid::Error.new('[form_builder] wrong attributes')
              attributes
            end
          end
        end


        def render_teasers(context)

          context_test = Hash.new
          context_test[:site] = context.registers[:site]

          if @new_att[:mode]=='mini'
            div_class_prefix = 'mini'
            under_title = '<img class="teaser-pfeil" src={{ "orange-pfeil.png" | theme_image_url }}>'
          else
            div_class_prefix = 'home'
            under_title = '<hr>'
          end

          content = ""
          context.registers[:page].teasers_dependencies.each do |i|
            #content = content + "{% include '#{i}' %}"
            teasers_content_type = context.registers[:site].content_types.where(slug: 'teasers').first

            teasers_content_entries = context.registers[:site].content_entries.where(content_type_id: teasers_content_type.id, _slug: i)

            teasers_content_entries.each do |teaser|
              content << '<div class="'+div_class_prefix+'-teaser">'
              if teaser.teaser_name.empty? and @new_att[:mode]=='mini'
                content << '<div class="'+div_class_prefix+'-teaser-title">'+teaser.teaser_title+'</div>'
                content << under_title
              elsif not teaser.teaser_name.empty?
                content << '<div class="'+div_class_prefix+'-teaser-title">'+teaser.teaser_name+'</div>'
                content << under_title
              end
              content << '<div class="'+div_class_prefix+'-teaser-content">'+teaser.teaser_body+'</div>
              </div>'
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
