module MentionableItems::PostProcess
  def self.add_links(doc, post)
    doc.css('span.mentionable-item').each do |span|
      slug = span.inner_html[1..]
      item = MentionableItem.find_by(slug: slug)

      if item.present?
        new_anchor = doc.document.create_element "a"
        new_anchor["href"] = item[:url]
        new_anchor["class"] = "mentionable-item"
        new_anchor["target"] = "_blank"

        new_span = doc.document.create_element "span"
        new_span.inner_html = item[:name]
        new_anchor.inner_html = new_span

        span.replace new_anchor
      end
    end
  end
end