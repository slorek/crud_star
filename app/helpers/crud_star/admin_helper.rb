module CrudStar
  module AdminHelper
    
    
    def navigation_hash
      
      nav = CrudStar::Engine.config.navigation
      
      if nav.class == Array
        hash = {}
        nav.each { |v| hash[v] = []  }
      end
      
      hash ||= nav
    end
    
  
    # Generates list headers with list ordering functionality.
    #
    # TODO: Association links.
    #
    def list_header_sortable(name, url, sort_field, conditions)
    
      # Add the ordering parameters to the URL.
      url += '?&order=' + sort_field
      url += '&desc=1' if (params[:order] == sort_field) and (params[:desc].nil?)
      
      params[:conditions].each_pair do |key, value|
        unless value.nil? or value.empty? or (value.class != String)
          url += '&conditions[' + key.to_s + ']=' + value.to_s
        end
      end
      
      name = name.html_safe
      
      # Add the current sort order indicator.
      if (params[:order] == sort_field)
        name += params[:desc].nil? ? image_tag('crud_star/sort_asc.gif', :alt => 'Ascending', :size => '10x8') : image_tag('crud_star/sort_desc.gif', :alt => 'Descending', :size => '10x8')
      end
    
      # Generate the link.
      link_to(name, url, :remote => true)
    end
  
  
    # Generates list pagination links using will_paginate. Adds list ordering
    # functionality.
    #
    def list_pagination_links(list, url)
      will_paginate(list, :renderer => CrudStar::RemoteLinkRenderer)
    end
  
  
    def get_value(item, attribute)
    
      hierarchy = attribute.to_s.split('.')
    
      count = 0
    
      while (count < hierarchy.size) do
      
        if association = item.class.reflections[hierarchy[count].to_sym]
          item = item.send(hierarchy[count])
        else
          value = item.send(hierarchy[count])
        end
      
        count += 1
      end
    
      if value.nil? and !item.respond_to?(attribute.to_sym) and item.class.respond_to?(:crud_star_options)
        value = get_value(item, item.class.crud_star_options[:default_attribute])
      end
    
      value
    end
  
  
  
    
  
  
  
  
    # Formats the value of an attribute for display.
    #
    def display_value(item, attribute)
    
      value = get_value(item, attribute)
    
      unless value.nil?
      
        case value.class.name
        
          when 'Time'
            value.strftime("%B %d, %Y %I:%M %p")
          when 'Date'
            value.strftime("%B %d, %Y")
          when 'String', 'Fixnum'
            value
          when 'BigDecimal'
            value.to_s.gsub(/0+$/, '').gsub(/\.$/, '')
          when 'TrueClass'
            'Yes'
          when 'FalseClass'
            'No'
          else
            #value.class.name
            unless value.class.crud_star_options[:resource].nil?
              link_to(get_value(value, value.class.crud_star_options[:default_attribute]), self.send(CrudStar::Utility.path_for_resource(value.class), value))
            else
              get_value(value, value.class.crud_star_options[:default_attribute])
            end
          end
      end
    end
    
  
  
    # Displays an HTML form field for an ActiveRecord object attribute.
    #
    # The @item variable must be available in the view from which this method is 
    # called from and should be an ActiveRecord object.
    #
    # Output is an HTML tag for the relevant form field.
    #
    # Arguments:
    #
    # attribute     String name of the model attribute to display
    #
    # TODO: text, date data types. HABTM associations. Text field class names not being rendered on associated
    #
    def display_field(item, attribute)
      
      partial = CrudStar::Utility.get_field(item.class, attribute)
      
      unless partial.nil?
      
        @item = item
        render(:partial => partial)
        
      else
    
        # Get the value of the attribute on the current model.
        value = get_value(item, attribute)
  
        field_id = item.class.name.underscore + '_' + attribute
        field_name = item.class.name.underscore + '[' + attribute + ']'
      
        # Check if this is an association to another model.
        if association = item.class.reflections[attribute.to_sym]
        
          # Check if this attribute is a belongs_to association. If so, display a
          # selection box.
          if association.belongs_to?
  
            field_id = item.class.name.underscore + '_' + attribute + '_id'
            field_name = item.class.name.underscore + '[' + attribute + '_id]'
            
            tag = render(:partial => CrudStar::Utility.get_partial(item.class, 'select_associated'), :locals => {:field_id => field_id, :field_name => field_name, :selected => item.send(attribute).to_param, :association => association})
          
          else
            tag = display_value(item, attribute)
          end
        
        # Display standard field.
        else
            
          # Get the attribute's database table column metadata.
          column = item.column_for_attribute(attribute)
        
          case column.type
          
            # Display a datetime field as a popup date picker with time.
            when :datetime
              tag = text_field_tag field_name, display_value(item, attribute), :class => 'datetime', :id => item.class.name.underscore + '_' + attribute
          
            # Display a date field as a popup date picker.
            when :date
              tag = text_field_tag field_name, display_value(item, attribute), :class => 'date', :id => item.class.name.underscore + '_' + attribute
  
            # Display a string field as a text field, the length determined by the
            # column's length metadata.
            when :string
            
              if column.limit <= 15
                size = 'small'
              elsif column.limit <= 35
                size = 'medium'
              else
                size = 'large'
              end
            
              tag = text_field_tag(field_name, display_value(item, attribute), :maxlength => column.limit, :class => size)
              
            # Display a string field as a text field, the length determined by the
            # column's length metadata.
            when :integer
            
              if column.limit == 1
                size = 4
              elsif column.limit == 2
                size = 6
              elsif column.limit == 3
                size = 8
              elsif column.limit == 4
                size = 11
              else
                size = 20
              end
            
              tag = text_field_tag(field_name, display_value(item, attribute), :maxlength => size, :size => size)
              
            # Display a string field as a text field, the length determined by the
            # column's length metadata.
            when :decimal
            
              size = column.limit + 1
            
              tag = text_field_tag(field_name, display_value(item, attribute), :maxlength => size, :size => size)
              
            when :text
              field_id = field_name
              tag = text_area_tag(field_name, display_value(item, attribute), :size => '100x5')
              
            
            when :boolean
            
              value = item.send(attribute)
              value ||= false
            
              if value == true
                tag = radio_button_tag(field_name, true, :checked => true) + ' ' + label_tag(field_name + '_true', 'Yes', :class => 'radio') + ' ' + radio_button_tag(field_name, false) + ' ' + label_tag(field_name + '_false', 'No', :class => 'radio')
              else
                tag = radio_button_tag(field_name, true) + ' ' + label_tag(field_name + '_true', 'Yes', :class => 'radio') + ' ' + radio_button_tag(field_name, false, :checked => true) + ' ' + label_tag(field_name + '_false', 'No', :class => 'radio')
              end
            
            else
              tag = text_field_tag(field_name, display_value(item, attribute))
          end
        end
      
        '<label for="' + field_id + '">' + attribute.split('.').last.humanize + '</label>' + tag
      end
    end
  
  
    # TODO: non-belongs_to fields
    #
    def display_filter(item, attribute)
      
      partial = CrudStar::Utility.get_filter(item.class, attribute)
      
      unless partial.nil?
          
        @item = item
        @value = params[:conditions][attribute.to_sym]
        render(:partial => partial)
        
      else
    
        field_id = 'conditions_' + attribute
        field_name = 'conditions[' + attribute + ']'
      
        # Check if this is an association to another model.
        if association = item.class.reflections[attribute.to_sym]
        
          # Check if this attribute is a belongs_to association. If so, display a
          # selection box.
          if association.belongs_to?
  
            field_id = 'conditions_' + attribute + '_id'
            field_name = 'conditions[' + attribute + '_id]'
            selected = params[:conditions][(attribute + '_id').to_sym]
            
            tag = render(:partial => CrudStar::Utility.get_partial(item.class, 'select_associated'), :locals => {:field_id => field_id, :field_name => field_name, :selected => selected, :association => association})
          end
        
        # Display standard field.
        else
        
          # Get the attribute's database table column metadata.
          column = item.column_for_attribute(attribute)
          value = params[:conditions][attribute.to_sym]
        
          case column.type
          
            # Display a datetime field as a popup date picker with time.
            when :datetime
            
              value ||= {:from => '', :to => ''}
            
              tag = '<br />'
              tag += label_tag(field_name + '[from]', 'From:') + ' '
              tag += '<span class="datetime">'
              tag += text_field_tag field_name + '[from]', value[:from], :class => 'datetime', :id => item.class.name.underscore + '_' + attribute
              tag += '</span>'
              tag += '<br />'
              tag += label_tag(field_name + '[to]', 'To:') + ' '
              tag += '<span class="datetime">'
              tag += text_field_tag field_name + '[to]', value[:to], :class => 'datetime', :id => item.class.name.underscore + '_' + attribute
              tag += '</span>'
                      
            # # Display a date field as a popup date picker.
            when :date
              tag = text_field_tag field_name, value, :class => 'date'
    
            # Display a string field as a text field, the length determined by the
            # column's length metadata.
            when :string
            
              if column.limit <= 15
                size = 'small'
              elsif column.limit <= 35
                size = 'medium'
              else
                size = 'large'
              end
            
              tag = text_field_tag(field_name, value, :maxlength => column.limit, :class => size)
              
            # Display a string field as a text field, the length determined by the
            # column's length metadata.
            when :integer
            
              if column.limit == 1
                size = 4
              elsif column.limit == 2
                size = 6
              elsif column.limit == 3
                size = 8
              elsif column.limit == 4
                size = 11
              else
                size = 20
              end
            
              tag = text_field_tag(field_name, value, :maxlength => size, :size => size)
              
            # Display a string field as a text field, the length determined by the
            # column's length metadata.
            when :decimal
            
              size = column.limit + 1
            
              tag = text_field_tag(field_name, value, :maxlength => size, :size => size)
              
            when :text
              field_id = field_name
              tag = text_area_tag(field_name, value, :size => '100x5')
              
            
            when :boolean
            
              if value == 'true'
                value = true
              elsif value == 'false'
                value = false
              else
                value = nil
              end
            
              tag = radio_button_tag(field_name, true, value == true) + ' ' +
                label_tag(field_name + '_true', 'Yes', :class => 'radio') + ' ' +
                radio_button_tag(field_name, false, value == false) + ' ' +
                label_tag(field_name + '_false', 'No', :class => 'radio') + ' ' +
                radio_button_tag(field_name, 'all', value == nil) + ' ' +
                label_tag(field_name + '_all', 'All', :class => 'radio')
            
            else
              tag = text_field_tag(field_name, display_value(item, attribute))
          end
        
        end
      
        '<label for="' + field_id + '">' + attribute.humanize + '</label> ' + tag
      end
    end
  end
end