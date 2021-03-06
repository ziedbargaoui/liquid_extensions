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

          content_type_id = @new_att[:content_type]


          context_test = Hash.new
          context_test[:site] = current_context.registers[:site]

          content_type = current_context.registers[:site].content_types.where(_id: content_type_id).first[:slug]

          entries_custom_fields = current_context.registers[:site].content_types.where(slug: content_type).first.attributes['entries_custom_fields']
          content_type_label_field_name = current_context.registers[:site].content_types.where(slug: content_type).first.attributes['label_field_name']

          entries_custom_fields.sort! {|left, right| left['position'] <=> right['position']}

          if content_type =~ /seminar/ || content_type =~ /termin/
            overview_fields = [content_type_label_field_name,'referent','beginn','location']
            mehr = 'details_zum_seminare'
          elsif content_type =~ /referent/
            overview_fields = [content_type_label_field_name,'land','url','seminare','bild']
            mehr = 'ueber_den_referent'
          elsif content_type =~ /news/
            overview_fields = [content_type_label_field_name,'datum','kurzbeschreibung']
            mehr = 'mehr'
          else
            overview_fields = [content_type_label_field_name]
            mehr = 'mehr'
          end

          # used to give unique ids for some elements used by jQuery functions (ex: Slider, Scroller)
          overivew_uuid = SecureRandom.hex(4)


          content = "<script>$(document).ready(

                      function() {
                      var listcount"+overivew_uuid+" = $('#overivew-list"+overivew_uuid+" #overivew-item"+overivew_uuid+"').size();
                      var cli"+overivew_uuid+" = 1;
                      $('#down"+overivew_uuid+"').click(function() {
                          if (cli"+overivew_uuid+" < listcount"+overivew_uuid+") {
                              $('#overivew-list"+overivew_uuid+" #overivew-item"+overivew_uuid+":nth-child(' + cli"+overivew_uuid+" + ')').slideToggle();
                              cli"+overivew_uuid+"++;
                          }
                      });
                      $('#up"+overivew_uuid+"').click(function() {
                          if (cli"+overivew_uuid+" > 1) {
                              cli"+overivew_uuid+"--;
                              $('#overivew-list"+overivew_uuid+" #overivew-item"+overivew_uuid+":nth-child(' + cli"+overivew_uuid+" + ')').slideToggle();
                          }
                      });
                      });
                      </script>

                      <a class='toggle-up-button' id='up"+overivew_uuid+"'>▲</a>

                      <div id='overivew-list"+overivew_uuid+"' class ='content-entries-overview' >"

            # Filtering and sorting
            if content_type =~ /seminar/ || content_type =~ /termin/
              content << "{% with_scope order_by: 'beginn asc' %}"
            elsif content_type =~ /news/ || content_type =~ /aktuelles/
              content << "{% with_scope order_by: 'datum desc' %}"
            end

            # Starting the main for that get the content entries

            content << "{% for entry in contents."+content_type+" %}"

            #Open the if that checks the Gultig_von gueltig_bis
            if content_type =~ /seminar/ || content_type =~ /termin/ || content_type =~ /news/ || content_type =~ /aktuelles/
              content <<"{% if entry.gueltig_von == null or entry.gueltig_von <= today %}
                          {% if entry.gueltig_bis == null or entry.gueltig_bis >= today %}"

            end

            content <<"<div id='overivew-item"+overivew_uuid+"' class ='content-entry'> "

          entries_custom_fields.each do |field_, array_|
            if overview_fields.include?(field_['name'])
              overview_fields[overview_fields.index(field_['name'].to_s)] = field_
            end
          end

          # if it's for seminare, then we have some special way to make the overview
          if content_type =~ /seminar/ || content_type =~ /termin/ || content_type =~ /referent/
            content << "<div class='seminare-overview'>"
          end

          i = 0
          overview_fields.each_with_index do |field, index|
            field_name = field['name']
            field_label = field['label']

            if content_type =~ /referent/ && index == 1
              @handle = content_type
              path = render_path(current_context)

              content << "<a href='"+path+"/{{entry._slug}}' >{{'"+mehr+"' | translate }}</a>"
            end


            #if overview_fields.include?(field_name)
            if  (content_type =~ /seminar/ || content_type =~ /termin/) &&  field_name =~ /beginn/
              content << "</div><div class='seminare-overview-2'>"
            elsif  content_type =~ /referent/  &&  field_name =~ /bild/
              content << "</div><div class='seminare-overview-2'>"
            end

              content << "<div class='content-entry-"+field_name+"'>"


              # This condition means that the field is a mapping to another content type, and it should be treated
              # differently, thus getting the related content entry.
              if not field['class_name'].nil?

                field_content_type_id = field['class_name']
                field_content_type_id = field_content_type_id.gsub("Locomotive::ContentEntry","")
                # get class of the related field's content_type, and its label_field_name
                related_field_content_type_label_field_name = current_context.registers[:site].content_types.where(_id: field_content_type_id).first[:label_field_name]

                # In case the field type is many_to_many then we need to get the real entry of the
                  #related field, and display it customly depending on the model.
                if field['type'] == 'many_to_many'

                  unless field_name =~ /bild/ || field_name =~ /photo/
                    content <<  "{% if entry."+field_name+"  != empty %} "+field_label+":<br>{% endif %}"
                  end
                  content  << "{% for sub_entry in entry."+field_name+" %}{% if sub_entry."+related_field_content_type_label_field_name+" != null %}"


                  if field_name =~ /referent/ || field_name =~ /seminar/ || field_name =~ /termin/
                    content_type_id = current_context.registers[:site].content_entries.where(_type: field['class_name']).first.attributes['content_type_id']
                    content_type_slug = current_context.registers[:site].content_types.where(_id: content_type_id).first.attributes['slug']
                    @handle = content_type_slug
                    path = render_path(current_context)

                    if field_name =~ /seminar/ || field_name =~ /termin/
                      content << "{% if sub_entry.beginn != null %} {{sub_entry.beginn | localized_date: '%d.%m.%Y', 'de' }} <br>{% endif %}"
                      content << "{% if sub_entry.location.titel  != empty %} {{ 'ort' | translate }}: {{sub_entry.location.titel}}<br>{% endif %}"
                      content << "{{sub_entry."+related_field_content_type_label_field_name+"}}<br>"
                      content  << "<a href='"+path+"/{{sub_entry._slug}}' >{{ 'details_zum_seminare' | translate}}</a>&nbsp;&nbsp;&nbsp;<a href='"+path+"/seminare_anmelden?entry_content_type="+content_type_slug+"&entry_id={{sub_entry._id}}' >{{'seminareanmeldung' | translate }}</a><br><br>"

                    else
                      content  << "<a href='"+path+"/{{sub_entry._slug}}' >{{sub_entry."+related_field_content_type_label_field_name+"}}</a><br>"
                    end


                  elsif field_name =~ /bild/ || field_name =~ /photo/
                    content  << "{{  sub_entry.file.url  | image_tag }}"
                  else
                    content  << "{{ sub_entry."+related_field_content_type_label_field_name+" }}  "
                  end

                  content  << " {% endif %} {% endfor %} "

                elsif field['type'] == 'belongs_to'
                  content << "{% if entry."+field_name+"."+related_field_content_type_label_field_name+" != null %}"+field_label+": {{ entry."+field_name+"."+related_field_content_type_label_field_name+" }} {% endif %}  "
                end
              # If the field to be displayed is of type data, that means it's file (mostly image)
                #in this case we need to extract its extension, if its image then display it in the
                # <img> tag, if it's file, then display it in the <a> tag with href to the file path
                # so the user can download it.  
              elsif field['type'] == 'data'
                content << "

                {% assign file_parts = entry."+field_name+" | split: '.' %}
                {% assign file_extension = file_parts | last  %}
                {% assign file_path = file_parts[0] | split: '/' %}
                {% assign file_name = file_path| last  %}
                {% assign image_extensions = 'bmp,gif,jpg,png,jpeg,jfif,tiff,tif,jp2,jpx,j2k,j2c,fpx,pcd' %}
                {% if image_extensions contains file_extension %}
                  {{ entry."+field_name+" | image_tag }}
                {% elsif entry."+field_name+" != null  %}
                  <a href='{{ entry."+field_name+"}}'>{{ file_name }}.{{file_extension}}</a>
                {% endif %}

                "
              elsif field['type'] == 'date'
                content << "{{ entry."+field_name+" | localized_date: '%d.%m.%Y', 'de' }} "
              elsif field['hint'] =~ /http/
                content << "<a href={{entry."+field_name+"}}> {{entry."+field_name+"}} </a>"
              else
                content << "{{ entry."+field_name+"}} "
              end

              content << "</div>"

            #end
          end

          
          # get the path to the template page of the content type
          @handle = content_type
          path = render_path(current_context)
          
          # some divs were specific to the seminares and referents models 
          # and here we should close them
          if content_type =~ /seminar/ || content_type =~ /termin/ || content_type =~ /referent/
            content << "</div>"
            content << "<div class='details_and_inscription'>"
          end

          # If the content type is referents then display the path to the detail view
          if content_type !~ /referent/
            content << "<a href='"+path+"/{{entry._slug}}' >{{'"+mehr+"' | translate }}</a>"
          end
          
          # If the content type is seminars then display the link to the registration page, otherwise
          # If it's referents, close the div
          if content_type =~ /seminar/ || content_type =~ /termin/
            content << "&nbsp;&nbsp;&nbsp;<a href='"+path+"/seminare_anmelden?entry_content_type="+content_type+"&entry_id={{entry._id}}' >{{'seminareanmeldung' | translate }}</a></div>"

          elsif content_type =~ /referent/
            content << "</div>"
          end



          content << "</div>"

          #Close the if that checks the Gultig_von gueltig_bis

          if content_type =~ /seminar/ || content_type =~ /termin/ || content_type =~ /news/ || content_type =~ /aktuelles/
            content <<"{% endif %}{% endif %}"
          end

          content <<"{% endfor %}</div>"

          # End Filtering and sorting
          if content_type =~ /seminar/ || content_type =~ /termin/ || content_type =~ /news/ || content_type =~ /aktuelles/
            content << "{% endwith_scope %}"
          end

          content << "<a class='toggle-down-button' id='down"+overivew_uuid+"'>▼</a>"
          content << "{% link_to "+content_type+" %} <b class='alle_ansehen'>{{'alle_ansehen' | translate }}</b> {% endlink_to %}"


          @template = ::Liquid::Template.parse(content,context.merge(context_test))

          rend = @template.render(current_context)

          return rend

        end

      end

      ::Liquid::Template.register_tag('entries_overview', EntriesOverview)
    end
  end
end