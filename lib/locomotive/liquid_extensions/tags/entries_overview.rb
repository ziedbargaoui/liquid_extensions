module Locomotive
  module LiquidExtensions
    module Tags

      class EntriesOverview < Solid::Block

        include Locomotive::Liquid::Tags::PathHelper
        include ActionView::Helpers::UrlHelper

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

          if content_type =~ /seminar/ || content_type =~ /termin/
            overview_fields = ['datum','title','referent','location']
          else
            overview_fields = ['title','datum','kurzbeschreibung']
          end

          # used to give unique ids for some elements used by jQuery functions (ex: Slider, Scroller)
          overivew_uuid = SecureRandom.hex(4)


          content = "<script>$(document).ready(

                      function() {
                      var listcount"+overivew_uuid+" = $('#overivew-list"+overivew_uuid+" li').size();
                      var cli"+overivew_uuid+" = 1;
                      $('#down"+overivew_uuid+"').click(function() {
                          if (cli"+overivew_uuid+" < listcount"+overivew_uuid+") {
                              $('#overivew-list"+overivew_uuid+" li:nth-child(' + cli"+overivew_uuid+" + ')').slideToggle();
                              cli"+overivew_uuid+"++;
                          }
                      });
                      $('#up"+overivew_uuid+"').click(function() {
                          if (cli"+overivew_uuid+" > 1) {
                              cli"+overivew_uuid+"--;
                              $('#overivew-list"+overivew_uuid+" li:nth-child(' + cli"+overivew_uuid+" + ')').slideToggle();
                          }
                      });
                      });
                      </script>

                      <a class='toggle-up-button' id='up"+overivew_uuid+"'>▲</a>

                      <ul id='overivew-list"+overivew_uuid+"' class ='content-entries-overview' > {% for entry in contents."+content_type+" %}

                        <li id='overivew-item"+overivew_uuid+"' class ='content-entry'>  "

          entries_custom_fields.each do |field, array|
            field_name = field['name']
            field_label = field['label']

            if overview_fields.include?(field_name)

              content << "<p class='content-entry-"

              if not field['class_name'].nil?

                if field['type'] == 'many_to_many'
                  content  << field_name+"'> {% for sub_entry in entry."+field_name+" %} {% if sub_entry.titel != null %} "+field_label+": {{ sub_entry.titel }} {% endif %} {% endfor %} "
                elsif field['type'] == 'belongs_to'
                  content << field_name+"'> {% if entry."+field_name+".titel != null %}"+field_label+": {{ entry."+field_name+".titel }} {% endif %}  "
                end

              elsif field['type'] == 'date'
                content << field_name+"'>{{ entry."+field_name+" | localized_date: '%d.%m.%Y', 'de' }} "
              else
                content << field_name+"'>{{ entry."+field_name+"}} "
              end

              content << "</p>"

            end
          end

          @handle = content_type
          path = render_path(current_context)

          content << "<a href='"+path+"/{{entry._slug}}' >{{'mehr' | translate }}</a></li>{% endfor %}</ul>"
          content << "<a class='toggle-down-button' id='down"+overivew_uuid+"'>▼</a>"
          content << "{% link_to "+content_type+" %} {{'alle_ansehen' | translate }} {% endlink_to %}"


          @template = ::Liquid::Template.parse(content,context.merge(context_test))

          rend = @template.render(current_context)

          return rend

        end

      end

      ::Liquid::Template.register_tag('entries_overview', EntriesOverview)
    end
  end
end
