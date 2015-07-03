module Locomotive
  module LiquidExtensions
    module Tags

      class EntriesOverview < Solid::Block

        def display(*options, &block)

          model_name, attributes = self.extract_model_name_and_attributes(options)
          @new_att = attributes
          self.render_overview(@context)
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
              puts attributes.inspect
              # the content entry should not be attached to another site or content type
              attributes.delete_if { |k, _| %w(site site_id content_type content_type_id).include?(k) }
            else
              #raise ::Liquid::Error.new('[form_builder] wrong attributes')
              attributes
            end
          end
        end


        def render_overview(context)

          content_type = @new_att[:content_type]


          context_test = Hash.new
          context_test[:site] = current_context.registers[:site]


          entries_custom_fields = current_context.registers[:site].content_types.where(slug: content_type).first.attributes['entries_custom_fields']
          entries_custom_fields.sort! {|left, right| left['position'] <=> right['position']}
          
           overview_fields = ['title','datum','kurzbeschreibung']

          content = "<div class ='content-entries-overview'>
                        <ul> {% for entry in contents."+content_type+" %}
                          
                        <li>
                          <div class ='content-entry'>"
                            entries_custom_fields.each do |field, array|
                              field_name = field['name']
                              if overview_fields.include?(field_name) 
                                content = content +"<p class='content-entry-"+field_name+"'>{{ entry."+field_name+" }}</p>"
                              end
                            end
          content = content + "</div></li>{% endfor %}</ul></div>"

          @template = ::Liquid::Template.parse(content,context.merge(context_test))

          rend = @template.render(current_context)

          return rend

        end

      end

      ::Liquid::Template.register_tag('entries_overview', EntriesOverview)
    end
  end
end
