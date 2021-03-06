module Locomotive
  module LiquidExtensions
    module Tags

      class Formbuilder < Solid::Block

        # register the tag
        tag_name :form_builder

        # not nil if processed from Wagon
        context_attribute :wagon

        def display(*options, &block)
          model_name, attributes = self.extract_model_name_and_attributes(options)
          form_html = self.build_form(model_name,attributes)
          return form_html
        end

        protected

        def build_form(model_name, model)

          content_type = self.fetch_content_type(model_name)
          entries_custom_fields = content_type.attributes['entries_custom_fields']
          entries_custom_fields.sort! {|left, right| left['position'] <=> right['position']}

          # used to get the labels when displaying the errors
          custom_fields_key_label = {}
          entries_custom_fields.each do |field|
            custom_fields_key_label[field['name']] = field['label']
          end

          if  model[:content_type].is_a?(Hash)
              errors =  model[:content_type]['errors']
              form_html = "<div style='color:red;'> <p>"+I18n.t('please_fill_the_mandatory_fields')+"</p> </div> "
              #errors.each do |error_key, error_value|
              #  if error_key.to_s != '_slug'
              #    error_label = custom_fields_key_label[error_key.to_s]
              #    form_html << '<li>' + error_label.to_s+" - "+error_value[0].to_s + '</li>'
              #  end
              #end
              #form_html << '</ul></div>'
          elsif model[:content_type].nil?
            form_html = ''
          else
            returned_message = "<script>_gaq.push(['_trackEvent', '"+content_type[:name].to_s+" Formular', 'Form Submit','"+content_type[:_id].to_s+"']);</script>"+content_type.attributes['returned_message'].to_s
            return returned_message
          end

          # this used for formulars that are specific to an entry (ex: seminares job, event)
          # An example is when the user goes to the seminareAnmeldung from the Seminare overview
          # Then in thic case the seminar name needs to be displayed at the top of the form, also
          # the seminare id needs to fill the hidden field seminars" if it exists

          params = model[:parameters]

          if not params[:entry_content_type].nil?
            entry_content_type = params[:entry_content_type]
            entry_id = params[:entry_id]
            entry_title = current_context.registers[:site].content_entries.where(id: entry_id).first.attributes['title']
            entry_datum = current_context.registers[:site].content_entries.where(id: entry_id).first.attributes['datum']
            if not entry_datum.nil?
              form_html << entry_datum.strftime("%d.%m.%Y").to_s
            end
            if not entry_title.nil?
              form_html << "<br><strong>"+entry_title+"</strong><br>"
            end
          end


          # Here we initialize the datepicker with localized dates

          form_html << "<script src='https://www.google.com/recaptcha/api.js' async defer></script><script>$(function() {
                        $( '.datepicker' ).datepicker({
                          dateFormat: 'dd.mm.yy',
                          monthNames: ['Januar','Februar','März','April','Mai','Juni','Juli','August','September','Oktober','November','Dezember'],
                          dayNames: ['Sonntag', 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag','Samstag'],
                          dayNamesMin: ['So', 'Mo', 'Die', 'Mi', 'Do', 'Fre', 'Sa']
                        });
                      });</script><table>"

          public_key = Recaptcha.configuration.public_key


          entries_custom_fields.each do |field, array|

              field_name = field['name']
              field_label = field['label']
              field_type = field['type']
              field_hint = field['hint']
              field_required = field['required']
              field_position = field['position']


              if  model[:content_type].is_a?(Hash)
                field_value =  model[:content_type]["#{field_name}"]
              end


              # The "required" star
              if field_required == true
                required_star = "*"
              else
                required_star = ""
              end

              # The select options
              string_options = ''
              field_type_tag = field_type
              input_tag = 'input'
              field_class = 'form_input'
              if field_type == 'select'
                input_tag = field_type
                field_select_options = field['select_options']
                option_en =''
                unless field_select_options.nil?
                  field_select_options.each do |option, array2|
                    option_en = option['name']['de']
                    if option_en == field_value
                      string_options = string_options+"<option selected >#{option_en}</option>"
                    else
                      string_options = string_options+"<option>#{option_en}</option>"
                    end
                  end
                end
              elsif field_type == 'boolean'
                field_type_tag = 'checkbox'

                if field_value == false
                  checkbox = ''
                  field_value = '0'
                else
                  checkbox = 'checked="checked"'
                  field_value = '1'
                end

              elsif field_type == 'date'
                field_class = 'datepicker'
                field_type_tag = 'text'
              elsif field_type == 'date_time'
                field_type_tag = 'datetime-local'
              elsif field_type == 'text'
                input_tag = 'textarea'
                unless field_value.nil?
                  string_options = field_value
                end
              elsif field_type == 'belongs_to'
                inverse_of = field['inverse_of']
                field_type_tag = 'hidden'
                unless entry_id.nil?
                  field_value = entry_id
                end
                form_html <<"<td>&nbsp;</td><td> <#{input_tag} type='#{field_type_tag}' class='#{field_class}' name='content[#{field_name}]' value='#{field_value}'/>"
                next
              elsif field_type == 'captcha'
                input_tag = 'textarea'
                form_html << '<tr><td>&nbsp;</td><td>&nbsp;</td><td><div class="g-recaptcha" data-sitekey="'+public_key+'"></div></td></tr>'
                next
              elsif field_type == 'free_html'
                form_html << '<tr>'+field['free_html_text']+'</tr>'
                next
              end

              form_html ="<tr><td>"+form_html +'</td>
                <td><label for ="'+field_label+'">'+ "#{field_label}"+"#{required_star}</label>
                </td><td>&nbsp;</td><td> <#{input_tag} type='#{field_type_tag}' class='#{field_class}' name='content[#{field_name}]' #{checkbox} value='#{field_value}'>"+string_options+"</#{input_tag}>"
              if not field_hint.nil?
                form_html << "<label class='field_hint'>"+field_hint+"</label>"
              end
              form_html <<  "</td></tr>"
          end

          form_html << ' <tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr><tr><td>&nbsp;</td><td>&nbsp;</td><td><input class="submit" type="submit"></td></tr></table>'


          return form_html


        end

        def fetch_content_type(model_name)
          if wagon
            current_context.registers[:mounting_point].content_types[model_name]
          else
            current_context.registers[:site].content_types.where(slug: model_name).first
          end
        end

        def extract_model_name_and_attributes(options)
          raise ::Liquid::Error.new('[form_builder] wrong number of parameters (1 is required)') if options.size < 1

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

        def log(model, persisted)
          message = persisted ? ["Model created !"] : ["Model not created :-("]
          message << "  attributes: #{model.to_s}"

          current_context.registers[:logger].info message.join("\n") + "\n\n"
        end

      end

    end
  end
end
