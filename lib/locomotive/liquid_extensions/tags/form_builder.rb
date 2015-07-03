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
          form_html = self.build_form(model_name)
          return form_html
        end

        protected

        def build_form(model_name)
          content_type = self.fetch_content_type(model_name)
          entries_custom_fields = content_type.attributes['entries_custom_fields']
          entries_custom_fields.sort! {|left, right| left['position'] <=> right['position']}
          form_html = '<table> <colgroup><col width="20"><col width="160"><col width="5"><col width="365"></colgroup>'
          entries_custom_fields.each do |field, array|

              field_name = field['name']
              field_label = field['label']
              field_type = field['type']
              field_hint = field['hint']
              field_required = field['required']
              field_position = field['position']

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

              if field_type == 'select'
                input_tag = field_type
                field_select_options = field['select_options']
                option_en =''
                field_select_options.each do |option, array2|
                  option_en = option['name']['de']
                  string_options = string_options+"<option>#{option_en}</option>"
                end
              elsif field_type == 'boolean'
                field_type_tag = 'radio'
              elsif field_type == 'date_time'
                field_type_tag = 'datetime-local'
              elsif field_type == 'text'
                input_tag = 'textarea'
              elsif field_type == 'belongs_to'
                inverse_of = field['inverse_of']
                content_type_of_inverse = self.fetch_content_type(inverse_of)
                entries = current_context.registers[:site].content_entries.where(_type: 'Locomotive::ContentEntry55476baeb3c714d91a000008')

              end

              form_html ='<tr><td>'+form_html +'</td>
                <td align="right" colspan="2" width="95"><label for ="'+field_label+'">'+ "#{field_label}"+"#{required_star}</label></td><td width='5'>&nbsp;</td><td width='155' align='left'> <#{input_tag} type='#{field_type_tag}' name='content[#{field_name}]' value>"+string_options+"</#{input_tag}></td></tr>"
          end
          form_html = form_html + '<tr><td>&nbsp;</td><td>&nbsp;</td><td><input type="submit"></td></tr></table>'


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
              puts attributes.inspect
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
