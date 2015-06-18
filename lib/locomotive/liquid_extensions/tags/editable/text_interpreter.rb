module Locomotive
  module LiquidExtensions
    module Tags
      module Editable
        class TextInterpreter < Locomotive::Liquid::Tags::Editable::Base

          include Locomotive::Render

          protected

          def render_element(context, element)
            content = element.default_content? ? render_default_content(context) : element.content

            context_test = Hash.new
            context_test[:site] = context.registers[:site]
            @template = ::Liquid::Template.parse(content,context.merge(context_test))

            rend = @template.render(context)

            if self.editable?(context, element)
              self.render_editable_element(element, content)
            else
              rend
            end
          end

          def render_editable_element(element, content)
            tag_name  = 'div'
            css       = 'editable-text_interpreter'

            unless element.line_break?
              tag_name  = 'span'
              css       += ' editable-single-text_interpreter'
            end

            %{
              <#{tag_name} class='#{css}' data-element-id='#{element.id}' data-element-index='#{element._index}'>
                #{content}
              </#{tag_name}>
            }
          end

          def document_type
            EditableText
          end

          def editable?(context, element)
            context.registers[:inline_editor] &&
            %(raw html).include?(element.format) &&
            (!element.fixed? || (element.fixed? && !element.from_parent?))
          end

          def default_element_attributes
            super.merge(
              content_from_default: self.render_default_content(nil),
              format:               @options[:format] || 'html',
              rows:                 @options[:rows] || 10,
              line_break:           @options[:line_break].blank? ? true : @options[:line_break]
            )
          end

        end

        ::Liquid::Template.register_tag('editable_text_interpreter', TextInterpreter)

        class ShortTextInterpreter < TextInterpreter
          def initialize(tag_name, markup, tokens, context_interpreter)
            Rails.logger.warn %(The "editable_<short|long>_text_interpreter" liquid tags are deprecated. Use "editable_text_interpreter" instead.)
            super
          end
          def default_element_attributes
            super.merge(format: 'raw', rows: 2, line_break: false)
          end
        end
        ::Liquid::Template.register_tag('editable_short_text_interpreter', ShortTextInterpreter)

        class LongTextInterpreter < ShortTextInterpreter
          def default_element_attributes
            super.merge(format: 'html', rows: 15, line_break: true)
          end
        end
        ::Liquid::Template.register_tag('editable_long_text_interpreter', LongTextInterpreter)

      end
    end
  end
end
