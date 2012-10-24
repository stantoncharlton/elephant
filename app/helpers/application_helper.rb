module ApplicationHelper

    def full_title(page_title)
        base_title = "Elephant"
        if page_title.empty?
            base_title
        else
            "#{base_title} | #{page_title}"
        end
    end


    def link_to_add_fields(name, f, association)
        new_object = f.object.send(association).klass.new
        id = new_object.object_id
        fields = f.fields_for(association, new_object, child_index: id) do |builder|
            render(association.to_s.singularize + "_fields", f: builder)
        end
        link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
    end



    class MenuTabBuilder < TabsOnRails::Tabs::Builder
        def open_tabs(options = {})
            @context.tag("ul", options, open = true)
        end

        def close_tabs(options = {})
            "</ul>".html_safe
        end

        def tab_for(tab, name, options, item_options = {})
            item_options[:class] = (current_tab?(tab) ? 'current' : '')
            @context.content_tag(:li, item_options) do
                @context.link_to(name, options)
            end
        end
    end

    def my_tabs_tag(options = {})
        tabs_tag(options.merge(:builder => MenuTabBuilder))
    end
end
