DiscourseEvent.on(:before_post_process_cooked) do |doc, post|
  MentionableItems::PostProcess.add_links(doc, post)
end

module MentionableItems::PostProcess
  def self.add_links(doc, post)
    # this has to mirror exactly what is done in the preview javascript!
    
    doc.css('span.mentionable-item').each do |span|

      name_slug = span.inner_html[1..]

      my_item = MentionableItem.find_by(name_slug: name_slug)

      new_anchor_node = doc.document.create_element "a"
      new_anchor_node["href"] = my_item[:url]
      new_anchor_node["class"] = "mentionable-item"

      new_span_node = doc.document.create_element "span"
      new_span_node.inner_html = name_slug
        
      new_anchor_node.inner_html = new_span_node

      span.replace new_anchor_node
    end
  end
end
